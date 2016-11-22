#!/usr/bin/env python

import sys, time, os

#sys.path = [
#'', 
#'/glade/apps/opt/python/2.7.7/gnu-westmere/4.8.2/lib/python2.7/site-packages',
#'/glade/apps/opt/python/2.7.7/gnu-westmere/4.8.2/lib/python2.7/',
#'/glade/apps/opt/matplotlib/1.4.3/gnu-westmere/4.8.2/lib/python2.7/site-packages/matplotlib-1.4.3-py2.7-linux-x86_64.egg/',
#'/glade/apps/opt/matplotlib/1.4.3/gnu-westmere/4.8.2/lib/python2.7/site-packages',
#'/glade/apps/opt/scipy/0.15.1/intel-autodispatch/14.0.2/lib/python2.7/site-packages',
#'/glade/apps/opt/numpy/1.8.1/intel-autodispatch/14.0.2/lib/python2.7/site-packages',
#'/glade/apps/opt/matplotlib/1.4.3/gnu-westmere/4.8.2/lib/python2.7/site-packages/pyparsing-2.0.3-py2.7.egg/',
#'/glade/apps/opt/python/2.7.7/gnu-westmere/4.8.2/lib/python2.7/lib-dynload/',
#'/glade/u/home/sobash/.python-eggs/netCDF4-1.1.1-py2.7-linux-x86_64.egg-tmp/',
#'/glade/apps/opt/netcdf4python/1.1.1/gnu-westmere/4.8.2/lib/python2.7/site-packages/netCDF4-1.1.1-py2.7-linux-x86_64.egg/'
#]


from webplot import webPlot, readGrid, saveNewMap

def log(msg): print time.ctime(time.time()),':', msg

#saveNewMap(newPlot.domain)
log('Begin Script')
stime = time.time()

newPlot = webPlot()
        
log('Reading Data')
newPlot.readEnsemble()

for dom in ['ANLYS']:
    file_not_created, num_attempts = True, 0
    while file_not_created and num_attempts <= 3:
        newPlot.domain = dom

        newPlot.createFilename()
        fname = newPlot.outfile
 
        log('Loading Map for %s'%newPlot.domain)
        newPlot.loadMap()

        log('Plotting Data')
        newPlot.plotFields()
        newPlot.plotTitleTimes()

        log('Writing Image')
        newPlot.saveFigure()

        if os.path.exists(fname):
            file_not_created = False 
            log('Created %s, %.1f KB'%(fname,os.stat(fname).st_size/1000.0))
    
        num_attempts += 1

etime = time.time()
log('End Plotting (took %.2f sec)'%(etime-stime))

