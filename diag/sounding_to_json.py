#!/usr/bin/env python

import datetime, json, time, os
from netCDF4 import MFDataset, chartostring
import numpy as np
#from sharppy.sharptab.profile import Profile, ConvectiveProfile
#from sharppy.sharptab import winds, params, interp, thermo, utils
#from sharppy.databases.sars import hail, supercell

def mag(u, v, missing=-9999):
    '''
    Compute the magnitude of a vector from its components

    Parameters
    ----------
    u : number, array_like
        U-component of the wind
    v : number, array_like
        V-component of the wind
    missing : number (optional)
        Optional missing parameter. If not given, assume default missing
        value from sharppy.sharptab.constants.MISSING

    Returns
    -------
    mag : number, array_like
        The magnitude of the vector (units are the same as input)

    '''
    u = np.ma.asanyarray(u).astype(np.float64)
    v = np.ma.asanyarray(v).astype(np.float64)
    u.set_fill_value(missing)
    v.set_fill_value(missing)
    if u.shape:
        u[u == missing] = np.ma.masked
        v[v == missing] = np.ma.masked
    else:
        if u == missing or v == missing:
            return np.ma.masked
    return np.ma.sqrt(u**2 + v**2)

def comp2vec(u, v, missing=-9999):
    '''
    Convert U, V components into direction and magnitude

    Parameters
    ----------
    u : number, array_like
        U-component of the wind
    v : number, array_like
        V-component of the wind
    missing : number (optional)
        Optional missing parameter. If not given, assume default missing
        value from sharppy.sharptab.constants.MISSING

    Returns
    -------
    wdir : number, array_like (same as input)
        Angle in meteorological degrees
    wspd : number, array_like (same as input)
        Magnitudes of wind vector (input units == output units)

    '''
    u = np.ma.asanyarray(u).astype(np.float64)
    v = np.ma.asanyarray(v).astype(np.float64)
    u.set_fill_value(missing)
    v.set_fill_value(missing)
    wdir = np.degrees(np.arctan2(-u, -v))
    if wdir.shape:
        u[u == missing] = np.ma.masked
        v[v == missing] = np.ma.masked
        wdir[u.mask] = np.ma.masked
        wdir[v.mask] = np.ma.masked
        wdir[wdir < 0] += 360
        wdir[np.fabs(wdir) < 1e-10] = 0.
    else:
        if u == missing or v == missing:
            return np.ma.masked, np.ma.masked
        if wdir < 0:
            wdir += 360
        if np.fabs(wdir) < 1e-10:
            wdir = 0.
    return wdir, mag(u, v)

basedir = "/glade/u/home/hclin/scripts/rt2015/diag/soundings"
#yyyymmddhh = datetime.datetime(2015,7,30,0,0,0).strftime('%Y%m%d%H')
#yyyymmddhh = datetime.datetime.utcnow().strftime('%Y%m%d00')
yyyymmddhh = os.environ['ANAL_DATE']
#os.system('mkdir -p %s/%s/sounding'%(basedir,yyyymmddhh))

outdir = "/glade/scratch/hclin/CONUS/wrfda/postdir/soundings"
try: output_dir = os.environ['GRAPHICS_RUN_DIR']
#except: output_dir = "%s/%s/sounding"%(basedir,yyyymmddhh)
except: output_dir = "%s/%s"%(outdir,yyyymmddhh)

if os.path.exists('%s/fhr_done_%s'%(output_dir,yyyymmddhh)):
  fha = open('%s/fhr_done_%s'%(output_dir,yyyymmddhh), 'r')
  fhdone = [ int(fhr.strip()) for fhr in fha.readlines() ]
  fha.close()
else: fhdone = []
print fhdone

fha = open('%s/fhr_done_%s'%(output_dir,yyyymmddhh), 'w')
for fhr in range(0,49):
    print 'forecast hour', fhr
    if fhr in fhdone: fha.write(str(fhr)+"\n"); continue
    
    RUN_DIR = '/glade/scratch/hclin/CONUS/wrfda/postdir/soundings'
    files = []
    sound = '%s/%s/sound_wrfda_Fhr_%03d.nc'%(RUN_DIR,yyyymmddhh,fhr)
    print sound
    if os.path.exists(sound): files.append(sound)
    if len(files) < 1: continue

    print time.ctime(time.time()),':', 'Reading data'
    numens = len(files)        
    fh = MFDataset(files)
    numstations = len(fh.dimensions['stations'])
    numlevels = len(fh.dimensions['bottom_top'])
    tmpc = fh.variables['TEMP_MODLEV'][:].reshape((numens,numlevels,numstations))
    dwpc = fh.variables['DEWPOINT_MODLEV'][:].reshape((numens,numlevels,numstations))
    hght = fh.variables['HEIGHT_MODLEV'][:].reshape((numens,numlevels,numstations))
    pres = fh.variables['PRESSURE_MODLEV'][:].reshape((numens,numlevels,numstations))
    ugrd = fh.variables['U_GRID_MODLEV'][:].reshape((numens,numlevels,numstations))
    vgrd = fh.variables['V_GRID_MODLEV'][:].reshape((numens,numlevels,numstations))
    stns = chartostring(fh.variables['stn'][:,0:3])
    times = fh.variables['Times'][:]
    lat = fh.variables['lat'][:]
    lon = fh.variables['lon'][:]
    fh.close()

    latlonstr = ['%.2f%.2f'%t for t in zip(lat,lon)]
    stn_names = np.where(stns == "", latlonstr, stns)

    # compute mean and append to end of array
    tmpc = np.append(tmpc, np.mean(tmpc, axis=0)[np.newaxis,:], axis=0)
    dwpc = np.append(dwpc, np.mean(dwpc, axis=0)[np.newaxis,:], axis=0)
    hght = np.append(hght, np.mean(hght, axis=0)[np.newaxis,:], axis=0)
    pres = np.append(pres, np.mean(pres, axis=0)[np.newaxis,:], axis=0)
    ugrd = np.append(ugrd, np.mean(ugrd, axis=0)[np.newaxis,:], axis=0)
    vgrd = np.append(vgrd, np.mean(vgrd, axis=0)[np.newaxis,:], axis=0)
    wdir, wspd = comp2vec(ugrd, vgrd)
    
    print time.ctime(time.time()),':', 'Writing JSON'
    lats, lons = [], []
    for i in range(numstations):
        #if stns[i] == "" and i%1 != 0: continue
        if stns[i] == "": continue
        json_output = { 'fhr':fhr, 'nens':numens,
                    'pres':pres[:,:,i].astype(np.int).tolist(),
                    'hght':hght[:,:,i].astype(np.int).tolist(),
                    'tmpc':(tmpc[:,:,i]*10).astype(np.int).tolist(),
                    'dwpc':(dwpc[:,:,i]*10).astype(np.int).tolist(),
                    'wdir':wdir[:,:,i].astype(np.int).tolist(),
                    'wspd':(wspd[:,:,i]*10).astype(np.int).tolist() 
                  }
        with open(output_dir+'/data_%s_fhr%02d.js'%(stn_names[i],fhr), 'w') as outfile: json.dump(json_output, outfile, separators=(',', ':'))
        outfile.close()
    #os.system('rsync -rvtz --rsh=ssh %s/*fhr%02d.js webpub.ucar.edu:~/web/img/%s/sounding'%(output_dir,fhr,yyyymmddhh))
    if (len(files) == 10): fha.write(str(fhr)+"\n")
fha.close()
