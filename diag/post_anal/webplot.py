import matplotlib.colors as colors
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import *
from datetime import *
import cPickle as pickle
import os, sys, time, argparse
import scipy.ndimage as ndimage
from netCDF4 import Dataset, MFDataset
from scipy import interpolate
import subprocess
from fieldinfo import *

class webPlot:
    '''A class to plot data from NCAR ensemble'''
    def __init__(self, domain=None):
        self.opts = parseargs()
        self.initdate = datetime.strptime(self.opts['date'], '%Y%m%d%H')
        self.title = self.opts['title']
        self.debug = self.opts['debug']
        self.autolevels = self.opts['autolevels']
        if domain is None: self.domain = self.opts['domain']
        else: self.domain = domain 
        if ',' in self.opts['timerange']: self.shr, self.ehr = map(int, self.opts['timerange'].split(','))
	else: self.shr, self.ehr = int(self.opts['timerange']), int(self.opts['timerange'])
        self.createFilename()
    
    def createFilename(self):
        for f in ['fill', 'contour','barb']: # CSS added this for loop and everything in it
           if 'name' in self.opts[f]:
              if 'thresh' in self.opts[f]:
                 prefx = self.opts[f]['name']+'_'+self.opts[f]['ensprod']+'_'+str(self.opts[f]['thresh'])   # CSS
              else:
                 #hcl prefx = self.opts[f]['name']+'_'+self.opts[f]['ensprod'] # CSS
                 prefx = self.opts[f]['name']
              break

        if self.shr == self.ehr:  # CSS
           self.outfile = prefx+'_f'+'%03d'%self.shr+'_'+self.domain+'.png' # 'test.png' # CSS
        else: # CSS
           self.outfile = prefx+'_f'+'%03d'%self.shr+'-f'+'%03d'%self.ehr+'_'+self.domain+'.png' # 'test.png' # CSS

    def loadMap(self):
        self.fig, self.ax, self.m  = pickle.load(open('/glade/p/nmmm0001/romine/rt2015/analysis_gfx/rt2015_%s.pk'%self.domain, 'r'))
        lats, lons = readGrid()
        self.x, self.y = self.m(lons,lats)

    def readEnsemble(self):
        self.data, self.missing_members = readEnsemble(self.initdate, timerange=[self.shr,self.ehr], fields=self.opts, debug=self.debug)
           
    def interpolateData(self):
        with open('stations.txt') as f: content = f.readlines()
        latlons = [ [ float(num[:-1]) for num in line.split()[-2:] ] for line in content ]
        latlons = np.array(latlons)[:,::-1]
        latlons[:,0] = -1*latlons[:,0]
        
        #lats, lons = readGrid()
        #latlons = zip(lons[10::40,10::40].flatten(), lats[10::40,10::40].flatten())

        f = interpolate.RegularGridInterpolator((self.y[:,0], self.x[0,:]), self.data['fill'][0], fill_value=-9999, bounds_error=False, method='linear')
        x_ob, y_ob = self.m(*zip(*latlons))
        fcst_val = f((y_ob,x_ob)) 

        fontdict = {'family':'monospace', 'size':9 }
        self.ax.cla()
        self.ax.axis('off')
        for i in range(fcst_val.size):
            if x_ob[i] < self.m.xmax and x_ob[i] > self.m.xmin and y_ob[i] < self.m.ymax and y_ob[i] > self.m.ymin and fcst_val[i] != -9999:
                self.ax.text(x_ob[i], y_ob[i], int(round(fcst_val[i])), fontdict=fontdict, ha='center', va='center')
 
    def plotTitleTimes(self):
        fontdict = {'family':'monospace', 'size':12, 'weight':'bold'}

        # place title and times above corners of map
        x0, y1 = self.ax.transAxes.transform((0,1))
        x0, y0 = self.ax.transAxes.transform((0,0))
        x1, y1 = self.ax.transAxes.transform((1,1))
        self.ax.text(x0, y1+10, self.title, fontdict=fontdict, transform=None)

        initstr  = self.initdate.strftime('Init: %a %Y-%m-%d %H UTC') 
        if ((self.ehr - self.shr) == 0):
            validstr = (self.initdate+timedelta(hours=self.shr)).strftime('Valid: %a %Y-%m-%d %H UTC')
        else:
            validstr1 = (self.initdate+timedelta(hours=(self.shr-1))).strftime('%a %Y-%m-%d %H UTC')
            validstr2 = (self.initdate+timedelta(hours=self.ehr)).strftime('%a %Y-%m-%d %H UTC')
            validstr = "Valid: %s - %s"%(validstr1, validstr2)

        self.ax.text(x1, y1+20, initstr, horizontalalignment='right', transform=None)
        self.ax.text(x1, y1+5, validstr, horizontalalignment='right', transform=None)

#        if len(self.missing_members) > 0:
#            missing_members = sorted(set([ (x%10)+1 for x in missing_members ])) #get member number from missing indices
#            missing_members_string = ', '.join(str(x) for x in missing_members)
#            self.ax.text(x1-5, y0+5, 'Missing members: %s'%missing_members_string, horizontalalignment='right', transform=None)

    def plotFields(self):
        if 'fill' in self.data:
            if self.opts['fill']['ensprod'] == 'paintball': self.plotPaintball()
            elif self.opts['fill']['ensprod'] == 'stamp': self.plotStamp()
            else: self.plotFill()
        
        if 'contour' in self.data:
            if self.opts['contour']['ensprod'] == 'spaghetti': self.plotSpaghetti()
            elif self.opts['contour']['ensprod'] == 'stamp': self.plotStamp()
            else: self.plotContour()
        
        if 'barb' in self.data:
            #self.plotStreamlines()
            self.plotBarbs()

        if self.opts['interp']: self.interpolateData()

    def plotFill(self):
        if self.autolevels:
            min, max = self.data['fill'][0].min(), self.data['fill'][0].max()
            levels = np.linspace(min, max, num=15)
            cmap = colors.ListedColormap(self.opts['fill']['colors'])
            norm = colors.BoundaryNorm(levels, cmap.N)
            extend, extendfrac = 'neither', 0.0
        else:
            levels = self.opts['fill']['levels']
            cmap = colors.ListedColormap(self.opts['fill']['colors'])
            extend, extendfrac = 'neither', 0.0
            if self.opts['fill']['ensprod'] in ['prob', 'neprob']:
                cmap = colors.ListedColormap(self.opts['fill']['colors'][:9])
                cmap.set_over(self.opts['fill']['colors'][-1])
                extend, extendfrac = 'max', 0.02
            norm = colors.BoundaryNorm(levels, cmap.N)

        if self.opts['fill']['name'] == 'avo500': self.data['fill'][0] = ndimage.gaussian_filter(self.data['fill'][0], sigma=4)

        cs1 = self.m.contourf(self.x, self.y, self.data['fill'][0], levels=levels, cmap=cmap, norm=norm, extend='max', ax=self.ax)

        # make axes for colorbar, 175px to left and 30px down from bottom of map 
        x0, y0 = self.ax.transAxes.transform((0,0))
        x, y = self.fig.transFigure.inverted().transform((x0+175,y0-29.5))
        cax = self.fig.add_axes([x,y,0.985-x,y/3.0])
        cb = plt.colorbar(cs1, cax=cax, orientation='horizontal', extend=extend, extendfrac=extendfrac, ticks=levels)
        cb.outline.set_linewidth(0.7)
    
    def plotContour(self):
        data = ndimage.gaussian_filter(self.data['contour'][0], sigma=10)
        if self.opts['contour']['name'] in ['sbcinh','mlcinh']: linewidth, alpha = 0.5, 0.75
        else: linewidth, alpha = 1.5, 1.0
        cs2 = self.m.contour(self.x, self.y, data, levels=self.opts['contour']['levels'], colors='k', linewidths=linewidth, ax=self.ax, alpha=alpha)
        plt.clabel(cs2, fontsize='small', fmt='%i')

    def plotBarbs(self):
        skip = self.opts['barb']['skip']
        cs2 = self.m.barbs(self.x[::skip,::skip], self.y[::skip,::skip], self.data['barb'][0][::skip,::skip], self.data['barb'][1][::skip,::skip], \
                     color='black', length=5.5, linewidth=0.25, sizes={'emptybarb':0.05}, ax=self.ax)
    
    def plotStreamlines(self):
        speed = np.sqrt(self.data['barb'][0]**2 + self.data['barb'][1]**2)
        lw = 5*speed/speed.max()
        cs2 = self.m.streamplot(self.x[0,:], self.y[:,0], self.data['barb'][0], self.data['barb'][1], color='k', density=3, linewidth=lw, ax=self.ax)
        cs2.lines.set_alpha(0.5)
        cs2.arrows.set_alpha(0.5) #apparently this doesn't work?

    def plotPaintball(self):
       rects, labels = [], []
       colorlist = self.opts['fill']['colors']
       levels = self.opts['fill']['levels']
       for i in range(self.data['fill'][0].shape[0]):
           cs = self.m.contourf(self.x, self.y, self.data['fill'][0][i,:], levels=levels, colors=[colorlist[i]], ax=self.ax, alpha=0.5)
           rects.append(plt.Rectangle((0,0),1,1,fc=colorlist[i]))
           labels.append("member %d"%(i+1))

       plt.legend(rects, labels, ncol=5, loc='right', bbox_to_anchor=(1.0,-0.05), fontsize=11, \
                  frameon=False, borderpad=0.25, borderaxespad=0.25, handletextpad=0.2)

    def plotSpaghetti(self):
       proxy = []
       colorlist = self.opts['contour']['colors']
       levels = self.opts['contour']['levels']
       data = ndimage.gaussian_filter(self.data['contour'][0], sigma=[0,10,10])
       for i in range(data.shape[0]):
           #cs = self.m.contour(self.x, self.y, data[i,:], levels=levels, colors=[colorlist[i]], linewidths=2, linestyles='solid', ax=self.ax)
           cs = self.m.contour(self.x, self.y, data[i,:], levels=levels, colors='k', linewidths=1, linestyles='solid', ax=self.ax)
           proxy.append(plt.Rectangle((0,0),1,1,fc=colorlist[i]))
       #plt.legend(proxy, ["member %d"%i for i in range(1,11)], ncol=5, loc='right', bbox_to_anchor=(1.0,-0.05), fontsize=11, \
       #           frameon=False, borderpad=0.25, borderaxespad=0.25, handletextpad=0.2)

    def plotStamp(self):
       fig_width_px, dpi = 1280, 90
       fig = plt.figure(dpi=dpi)

       num_rows, num_columns = 3, 4
       fig_width = fig_width_px/dpi
       width_per_panel = fig_width/float(num_columns)
       height_per_panel = width_per_panel*self.m.aspect
       fig_height = height_per_panel*num_rows
       fig_height_px = fig_height*dpi
       fig.set_size_inches((fig_width, fig_height))

       levels = self.opts['fill']['levels']
       cmap = colors.ListedColormap(self.opts['fill']['colors'])
       norm = colors.BoundaryNorm(levels, cmap.N)
       
       for j in range(0,num_rows):
           for i in range(0,num_columns):
               member = num_columns*j+i
               if member > 9: break
               spacing_w, spacing_h = 5/float(fig_width_px), 5/float(fig_height_px)
               spacing_w = 10/float(fig_width_px)
               x, y = i*width_per_panel/float(fig_width), 1.0 - (j+1)*height_per_panel/float(fig_height)
               w, h = (width_per_panel/float(fig_width))-spacing_w, (height_per_panel/float(fig_height))-spacing_h
               if member == 9: y = 0

               #print 'member', member, 'creating axes at', x, y
               thisax = fig.add_axes([x,y,w,h])

               thisax.axis('on')
               for axis in ['top','bottom','left','right']: thisax.spines[axis].set_linewidth(0.5)
               self.m.drawcoastlines(ax=thisax, linewidth=0.3)
               self.m.drawstates(linewidth=0.15, ax=thisax)
               self.m.drawcountries(ax=thisax, linewidth=0.3)
               thisax.text(0.03,0.97,member+1,ha="left",va="top",bbox=dict(boxstyle="square",lw=0.5,fc="white"), transform=thisax.transAxes)
               if member not in self.missing_members: 
                   cs1 = self.m.contourf(self.x, self.y, self.data['fill'][0][member,:], levels=levels, cmap=cmap, norm=norm, extend='max', ax=thisax)
       
       cax = fig.add_axes([0.5,0.3,0.49,0.02])
       cb = plt.colorbar(cs1, cax=cax, orientation='horizontal',extendrect=True)
       cb.outline.set_linewidth(0.7)

       fontdict = {'family':'monospace', 'size':13, 'weight':'bold'}
       initstr  = self.initdate.strftime('Init: %a %Y-%m-%d %H UTC')
       if ((self.ehr - self.shr) == 0):
            validstr = (self.initdate+timedelta(hours=self.shr)).strftime('Valid: %a %Y-%m-%d %H UTC')
       else:
            validstr1 = (self.initdate+timedelta(hours=(self.shr-1))).strftime('%a %Y-%m-%d %H UTC')
            validstr2 = (self.initdate+timedelta(hours=self.ehr)).strftime('%a %Y-%m-%d %H UTC')
            validstr = "Valid: %s - %s"%(validstr1, validstr2)

       fig.text(0.5, 0.25, self.title, fontdict=fontdict, transform=fig.transFigure)
       fig.text(0.5, 0.22, initstr, transform=fig.transFigure)
       fig.text(0.5, 0.20, validstr, transform=fig.transFigure)

    def saveFigure(self, trans=False):
        # place NCAR logo 57 pixels below bottom of map, then save image 
        if not trans:
          x, y = self.ax.transAxes.transform((0,0))
          self.fig.figimage(plt.imread('ncar.png'), xo=x, yo=(y-57), zorder=1000)
          
        plt.savefig(self.outfile, dpi=90, transparent=trans)
        
        if self.opts['convert']:
            command = 'convert -trim -colors 255 %s %s'%(self.outfile, self.outfile)
            ret = subprocess.check_call(command.split())

def parseargs():
    '''Parse arguments and return dictionary of fill, contour and barb field parameters'''

    parser = argparse.ArgumentParser(description='Web plotting script for NCAR ensemble')
    parser.add_argument('-d', '--date', required=True, help='initialization datetime (YYYYMMDDHH)')
    parser.add_argument('-tr', '--timerange', required=True, help='time range of forecasts (START,END)')
    parser.add_argument('-f', '--fill', help='fill field (FIELD_PRODUCT_THRESH), field keys:'+','.join(fieldinfo.keys()))
    parser.add_argument('-c', '--contour', help='contour field (FIELD_PRODUCT_THRESH)')
    parser.add_argument('-b', '--barb', help='barb field (FIELD_PRODUCT_THRESH)')
    parser.add_argument('-bs', '--barbskip', help='barb skip interval')
    parser.add_argument('-t', '--title', help='title for plot')
    parser.add_argument('-dom', '--domain', default='ANLYS', help='domain to plot')
    parser.add_argument('-al', '--autolevels', action='store_true', help='use min/max to determine levels for plot')
    parser.add_argument('-con', '--convert', default=True, action='store_false', help='run final image through imagemagick')
    parser.add_argument('-i', '--interp', action='store_true', help='plot interpolated station values')
    parser.add_argument('--debug', action='store_true', help='turn on debugging')

    opts = vars(parser.parse_args())
    # opts = { 'date':date, 'timerange':timerange, 'fill':'sbcape_prob_25', 'ensprod':'mean' ... }

    # now, convert underscore delimited fill, contour, and barb args into dicts
    for f in ['contour','barb','fill']:
        thisdict = {}
        if opts[f] is not None:
            input = opts[f].lower().split('_')

            thisdict['name']      = input[0]
            thisdict['ensprod']   = input[1]
            thisdict['arrayname'] = fieldinfo[input[0]]['fname']
            
            # assign contour levels and colors
            if (input[1] in ['prob', 'neprob']):
                thisdict['thresh']  = float(input[2])
                thisdict['levels']  = np.arange(0.1,1.1,0.1)
                thisdict['colors']  = readNCLcm('perc2_9lev')
            elif (input[1] in ['paintball', 'spaghetti']):
                thisdict['thresh']  = float(input[2])
                thisdict['levels']  = [float(input[2]), 1000]
                thisdict['colors']  = readNCLcm('GMT_paired') 
            elif (input[1] == 'var'):
                if (input[0][0:3] == 'hgt'):
                    thisdict['levels']  = [1,2,3,4,5,7.5,10,12.5,15,17.5,20,22.5,25,30,35,40,45,50] #hgt 
                    thisdict['colors']  = readNCLcm('wind_17lev')
                elif (input[0][0:3] == 'iso'):
                    thisdict['levels']  = [1,2,3,4,5,7.5,10,12.5,15,17.5,20,22.5,25,30,35,40,45,50] #hgt 
                    thisdict['colors']  = readNCLcm('wind_17lev')
                elif (input[0][0:2] == 'td'):
                    thisdict['levels']  = [1,2,3,4,5,7.5,10,12.5,15,17.5,20,22.5,25,30,35,40,45,50] #hgt 
                    thisdict['colors']  = readNCLcm('wind_17lev')
                else:
                    thisdict['levels']  = [0.1,0.2,0.3,0.4,0.5,0.75,1,2,3,4,5] #tmp/td 
                    thisdict['colors']  = readNCLcm('perc2_9lev')
            elif 'levels' in fieldinfo[input[0]]:
                thisdict['levels']  = fieldinfo[input[0]]['levels']
                thisdict['colors']  = fieldinfo[input[0]]['cmap']
          
            # get vertical array index for 3D array fields
            if 'arraylevel' in fieldinfo[input[0]]:
                thisdict['arraylevel'] = fieldinfo[input[0]]['arraylevel']
            # surface level flag for array shape differences
            if 'sfclevel' in fieldinfo[input[0]]:
                thisdict['sfclevel'] = fieldinfo[input[0]]['sfclevel'] 
            # get barb-skip for barb fields
            if opts['barbskip'] is not None:    thisdict['skip'] = int(opts['barbskip'])
            elif 'skip' in fieldinfo[input[0]]: thisdict['skip'] = fieldinfo[input[0]]['skip']
            
            # get filename
            if 'filename' in fieldinfo[input[0]]: thisdict['filename'] = fieldinfo[input[0]]['filename']
            else:                                 thisdict['filename'] = 'amem'

        opts[f] = thisdict
    return opts

def makeEnsembleList(wrfinit, timerange):
    # create lists of files (and missing file indices) for various file types
    shr, ehr = timerange
    file_list    = { 'amem': [], 'fmem': [], 'incr':[] }
    missing_list = { 'amem': [], 'fmem': [], 'incr':[] }
   
    RUN_DIR = '/glade/scratch/hclin/CONUS/wrfda/postdir/webplot'
    missing_index = 0
    for hr in range(shr,ehr+1):
            wrfvalidstr = (wrfinit + timedelta(hours=hr)).strftime('%Y-%m-%d_%H:%M:%S')
            yyyymmddhh = wrfinit.strftime('%Y%m%d%H')
            #for mem in range(1,51):
            for mem in range(1,2):
                amem  = '%s/an_%s_all.nc'%(RUN_DIR,yyyymmddhh)
                fmem  = '%s/fg_%s_all.nc'%(RUN_DIR,yyyymmddhh)
                incr  = '%s/increment_%s.nc'%(RUN_DIR,yyyymmddhh)
                if os.path.exists(amem): file_list['amem'].append(amem)
                else: missing_list['amem'].append(missing_index)
                if os.path.exists(fmem): file_list['fmem'].append(fmem)
                else: missing_list['fmem'].append(missing_index)
                if os.path.exists(incr): file_list['incr'].append(incr)
                else: missing_list['incr'].append(missing_index)
                missing_index += 1
    return (file_list, missing_list)

def readEnsemble(wrfinit, timerange=None, fields=None, debug=False):
    ''' Reads in desired fields and returns 2-D arrays of data for each field (barb/contour/field) '''
    if debug: print fields

    datadict = {}
    file_list, missing_list = makeEnsembleList(wrfinit, timerange) #construct list of files
 
    # loop through fill field, contour field, barb field and retrieve required data
    for f in ['fill', 'contour', 'barb']:
        if not fields[f].keys(): continue
        if debug: print 'Reading field:', fields[f]['name'], 'from', fields[f]['filename']
        
        # save some variables for use in this function
        filename = fields[f]['filename']
        arrays = fields[f]['arrayname']
        fieldtype = fields[f]['ensprod']
        if fieldtype in ['prob', 'neprob']: thresh = fields[f]['thresh']
        if fieldtype[0:3]=='mem': member = int(fieldtype[3:])
        
        # open Multi-file netcdf dataset
	if debug: print file_list[filename] 
        fh = MFDataset(file_list[filename])
       
        # loop through each field, wind fields will have two fields that need to be read
        datalist = []
        for array in arrays:
            # read in 3D array (times*members,ny,nx) from file object 
            if 'arraylevel' in fields[f]:
                if fields[f]['arraylevel'] != 'max': data = fh.variables[array][:,0,fields[f]['arraylevel'],:,:]
                else: 				     data = np.amax(fh.variables[array][:,0,:,:,:], axis=1)
#GSR            else:                                    data = fh.variables[array][:,0,:,:]
#            elif 'sfclevel' in fields[f]:            data = fh.variables[array][:,:,:]
            else:                                    data = fh.variables[array][:,0,:,:]
#            else:                                    data = fh.variables[array][:,:,:]
            
            # change units for certain fields
            if array in ['U_GRID_PRS', 'V_GRID_PRS', 'UBSHR6','VBSHR6','U10','V10', 'U_COMP_STM', 'V_COMP_STM','S_PL']:  data = data*1.93 # m/s > kt
            if array in ['mean_V10_d01','mean_U10_d01']:  data = data*1.93*10.0 # m/s > .1 kt
            if array in ['MSL_PRES']:  data = data/100. # mb
            if array in ['P_WAT']:  data = data*0.0393701 # mb
            elif array in ['DEWPOINT_2M', 'T2', 'AFWA_WCHILL', 'AFWA_HEATIDX']:   data = (data - 273.15)*1.8 + 32.0 # K > F 
            elif array in ['PREC_ACC_NC', 'PREC_ACC_C', 'AFWA_PWAT', 'PWAT', 'AFWA_SNOWFALL', 'AFWA_SNOW', 'AFWA_ICE', 'AFWA_FZRA']:   data = data*0.0393701 # mm > in 
            elif array in ['RAINNC', 'GRPL_MAX', 'SNOW_ACC_NC']:  data = data*0.0393701 # mm > in 
            elif array in ['TEMP_PRS', 'DEWPOINT_PRS', 'SFC_LI']:            data = data - 273.15 # K > C
            elif array in ['ABS_VORT_PRS']:                       data = data*100000.0
            elif array in ['AFWA_MSLP', 'MSLP']:                  data = data*0.01 # Pa > hPa
            elif array in ['ECHOTOP']:                            data = data*0.001  # m > km
            elif array in ['SBCINH', 'MLCINH', 'W_DN_MAX']:       data = data*-1.0 # make cin positive
            elif array in ['PVORT_320K']:                         data = data*1000000 # multiply by 1e6
            elif array in ['SBT123_GDS3_NTAT']:                   data = data -273.15 # K -> C
            elif array in ['SBT124_GDS3_NTAT']:                   data = data -273.15 # K -> C
            elif array in ['HAIL_MAXK1', 'HAIL_MAX2D']:           data = data*39.3701 #  m -> inches
            elif array in ['mean_T2_d01']:                        data = data*1.8 # C->F
            elif array in ['T_LEV1']:                             data = data*1.8 + 32.0 # C->F

            # perform mean/max/variance/etc to reduce 3D array to 2D
            if (fieldtype == 'mean'):  data = np.mean(data, axis=0)
            elif (fieldtype == 'pmm'): data = compute_pmm(data)
            elif (fieldtype == 'max'): data = np.amax(data, axis=0)
            elif (fieldtype == 'var'): data = np.std(data, axis=0)
            elif (fieldtype == 'summean'):
                for i in missing_list[filename]: data = np.insert(data, i, np.nan, axis=0) #insert nan for missing files
                data = np.reshape(data, (data.shape[0]/10,10,data.shape[1],data.shape[2]))
                data = np.nansum(data, axis=0)
                data = np.nanmean(data, axis=0)
            elif (fieldtype[0:3] == 'mem'):
                for i in missing_list[filename]: data = np.insert(data, i, np.nan, axis=0) #insert nan for missing files
                data = np.reshape(data, (data.shape[0]/10,10,data.shape[1],data.shape[2]))
                data = np.nanmax(data, axis=0)
                data = data[member-1,:]
            elif (fieldtype in ['prob', 'neprob']):
                data = (data>=thresh).astype('float')
                for i in missing_list[filename]: data = np.insert(data, i, np.nan, axis=0) #insert nan for missing files
                data = np.reshape(data, (data.shape[0]/10,10,data.shape[1],data.shape[2]))
                data = np.nanmax(data, axis=0)
                if (fieldtype == 'neprob'): data = compute_neprob(data, roi=14, sigma=40) #nw=neighborhood width
                else: data = np.nanmean(data, axis=0) 
                data = data+0.001 #hack to ensure that plot displays discrete prob values

            if debug: print 'Returning', array, 'with shape', data.shape, 'max', data.max(), 'min', data.min()

            datalist.append(data)

        # attach data arrays for each type of field (e.g. { 'fill':[data], 'barb':[data,data] })
        datadict[f] = datalist
        fh.close()

    # these are derived fields, we don't have in any of the input files but we can compute
    if 'name' in fields['fill']:
      if fields['fill']['name'] in ['shr06mag', 'shr01mag', 'bunkmag']: datadict['fill'] = [np.sqrt(datadict['fill'][0]**2 + datadict['fill'][1]**2)]
      if fields['fill']['name'] in ['iso300', 'iso500', 'iso700', 'iso850']: datadict['fill'] = [np.sqrt(datadict['fill'][0]**2 + datadict['fill'][1]**2)]
      elif fields['fill']['name'] == 'stp': datadict['fill'] = computestp(datadict['fill'])

    return (datadict, missing_list['amem'])

def readGrid():
    f = Dataset('/glade/p/nmmm0001/romine/rt2015/analysis_gfx/rt2015_latlon_d01.nc', 'r')
    lats   = f.variables['XLAT'][0,:]
    lons   = f.variables['XLONG'][0,:]
    f.close()
    return (lats,lons)

def saveNewMap(domstr='ANLYS'):
    ll_lat, ll_lon, ur_lat, ur_lon = domains[domstr]['corners']
    fig_width = domains[domstr]['fig_width']
    lat_1, lat_2, lon_0 = 32.0, 46.0, -101.0
    dpi = 90

    fig = plt.figure(dpi=dpi)
    m = Basemap(projection='lcc', resolution='i', llcrnrlon=ll_lon, llcrnrlat=ll_lat, urcrnrlon=ur_lon, urcrnrlat=ur_lat, \
                lat_1=lat_1, lat_2=lat_2, lon_0=lon_0, area_thresh=1000)

    # compute height based on figure width, map aspect ratio, then add some vertical space for labels/colorbar
    fig_width  = fig_width/float(dpi)
    fig_height = fig_width*m.aspect + 1.25
    figsize = (fig_width, fig_height)
    fig.set_size_inches(figsize)
  
    # place map 0.8" from bottom of figure, leave 0.45" at top for title (needs to be in figure-relative coords)
    x,y,w,h = 0.01, 0.8/float(fig_height), 0.98, 0.98*fig_width*m.aspect/float(fig_height)
    ax = fig.add_axes([x,y,w,h])

    m.drawcoastlines(linewidth=0.5, ax=ax)
    m.drawstates(linewidth=0.25, ax=ax)
    m.drawcountries(ax=ax)
    #m.drawcounties(ax=ax, linewidth=0.25, color='gray')

    pickle.dump((fig,ax,m), open('rt2015_%s.pk'%domstr, 'w'))


def compute_pmm(ensemble):
    mem, dy, dx = ensemble.shape
    ens_mean = np.mean(ensemble, axis=0)
    ens_dist = np.sort(ensemble.flatten())[::-1]
    pmm = ens_dist[::mem]

    ens_mean_index = np.argsort(ens_mean.flatten())[::-1]
    temp = np.empty_like(pmm)
    temp[ens_mean_index] = pmm

    temp = np.where(ens_mean.flatten() > 0, temp, 0.0)
    return temp.reshape((dy,dx))

def compute_neprob(ensemble, roi=0, sigma=0):
    y,x = np.ogrid[-roi:roi+1, -roi:roi+1]
    kernel = x**2 + y**2 <= roi**2
    ens_roi = ndimage.filters.maximum_filter(ensemble, footprint=kernel[np.newaxis,:])

    ens_mean = np.nanmean(ens_roi, axis=0)

    #y,x = np.ogrid[-40:40+1, -nw:nw+1]
    #kernel = x**2 + y**2 <= 40**2
    #neprob = ndimage.filters.convolve(ens_mean, kernel/float(kernel.sum()))
    ens_mean = ndimage.filters.gaussian_filter(ens_mean, sigma)
    return ens_mean

def computestp(data):
    '''Compute STP with data array of [sbcape,sblcl,0-1srh,ushr06,vshr06]'''
    sbcape_term = (data[0]/1500.0)

    lcl_term = ((2000.0 - data[1])/1000.0)
    lcl_term = np.where(data[1] < 1000.0, 1.0, lcl_term)
    lcl_term = np.where(data[1] > 2000.0, 0.0, lcl_term)

    srh_term = (data[3]/150.0)

    shear06 = np.sqrt(data[4]**2 + data[5]**2) #this will be in knots (converted prior to fn)
    shear_term = (shear06/38.87)
    shear_term = np.where(data[4] > 58.32, 1.5, shear_term)
    shear_term = np.where(data[4] < 24.3, 0.0, shear_term)

    return (sbcape_term * lcl_term * srh_term * shear_term)

def showKeys():
    print fieldinfo.keys()
    sys.exit()
