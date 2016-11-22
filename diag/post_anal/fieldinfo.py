def readcm(name):
    '''Read colormap from file formatted as 0-1 RGB CSV'''
    rgb = []
    fh = open(name, 'r')
    for line in fh.read().splitlines(): rgb.append(map(float,line.split()))
    return rgb

def readNCLcm(name):
    '''Read in NCL colormap for use in matplotlib'''
    rgb, appending = [], False
    fh = open('/glade/apps/opt/ncl/6.2.0/intel/12.1.5/lib/ncarg/colormaps/%s.rgb'%name, 'r')
    for line in fh.read().splitlines():
        if appending: rgb.append(map(float,line.split()))
        if ''.join(line.split()) in ['#rgb',';RGB']: appending = True
    maxrgb = max([ x for y in rgb for x in y ])
    if maxrgb > 1: rgb = [ [ x/255.0 for x in a ] for a in rgb ]
    return rgb

fieldinfo = {
  # surface and convection-related entries
  'precip'       :{ 'levels' : [0,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.75,1,1.5,2,2.5,3.0], 'cmap': [readNCLcm('precip2_17lev')[i] for i in (0,1,2,4,5,6,7,8,10,12,13,14,15)], 'fname':['PREC_ACC_NC'] },
  'precipacc'    :{ 'levels' : [0,0.01,0.05,0.1,0.25,0.5,0.75,1.0,1.25,1.5,2.0,2.5,3.0,4.0], 'cmap': [readNCLcm('precip2_17lev')[i] for i in (0,1,2,4,5,6,7,8,10,12,13,14,15)], 'fname':['RAINNC'] },
  'sbcape'       :{ 'levels' : [100,250,500,750,1000,1250,1500,1750,2000,2500,3000,3500,4000,4500,5000,5500,6000],
                    'cmap'   : ['#eeeeee', '#dddddd', '#cccccc', '#aaaaaa']+readNCLcm('precip2_17lev')[3:-1], 'fname': ['SBCAPE'], 'filename':'upp' },
  'mlcape'       :{ 'levels' : [100,250,500,750,1000,1250,1500,1750,2000,2500,3000,3500,4000,4500,5000,5500,6000],
                    'cmap'   : ['#eeeeee', '#dddddd', '#cccccc', '#aaaaaa']+readNCLcm('precip2_17lev')[3:-1], 'fname': ['MLCAPE'], 'filename':'upp', 'arraylevel':0 },
  'mucape'       :{ 'levels' : [100,250,500,750,1000,1250,1500,1750,2000,2500,3000,3500,4000,4500,5000,5500,6000],
                    'cmap'   : ['#eeeeee', '#dddddd', '#cccccc', '#aaaaaa']+readNCLcm('precip2_17lev')[3:-1], 'fname': ['MLCAPE'], 'filename':'upp', 'arraylevel':2 },
  'sbcinh'       :{ 'levels' : [50,75,100,150,200,250,500], 'cmap': readNCLcm('topo_15lev')[1:], 'fname': ['SBCINH'], 'filename':'upp' },
  'mlcinh'       :{ 'levels' : [50,75,100,150,200,250,500], 'cmap': readNCLcm('topo_15lev')[1:], 'fname': ['MLCINH'], 'filename':'upp', 'arraylevel':0 },
  'pwat'         :{ 'levels' : [0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.5,3.0,3.5,4.0],
                    'cmap'   : ['#dddddd', '#cccccc', '#e1e1d3', '#e1d5b1', '#ffffd5', '#e5ffa7', '#addd8e', '#41ab5d', '#007837', '#005529', '#0029b1'],
                    'fname'  : ['P_WAT'] },
  'hailk1'       :{ 'levels' : [0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.5,3.0,3.5,4.0], 'cmap': [readNCLcm('precip2_17lev')[i] for i in (1,2,4,5,6,7,8,10,12,13,14,15,16)], 'fname':['HAIL_MAXK1'], 'filename': 'diag' },
  'hail2d'       :{ 'levels' : [0.25,0.5,0.75,1.0,1.25,1.5,1.75,2.0,2.5,3.0,3.5,4.0], 'cmap': [readNCLcm('precip2_17lev')[i] for i in (1,2,4,5,6,7,8,10,12,13,14,15,16)], 'fname':['HAIL_MAX2D'], 'filename': 'diag' },
  'templ0'       :{ 'levels' : [-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['T_LEV1'] },
  't2'           :{ 'levels' : [-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['T2'] },
  't2inc'        :{ 'levels' : [-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T2'], 'filename':'incr', 'sfclevel':0 },
#  't2inc'        :{ 'levels' : [-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['mean_T2_d01'], 'filename':'incr' },
  'mslp'         :{ 'levels' : [960,964,968,972,976,980,984,988,992,996,1000,1004,1008,1012,1016,1020,1024,1028,1032,1036,1040,1044,1048,1052], 'cmap':readNCLcm('nice_gfdl')[3:193], 'fname':['MSL_PRES'] },
  'td2'          :{ 'levels' : [20,25,30,35,40,45,50,55,60,64,68,72,76],
                    'cmap'   : ['#eeeeee', '#dddddd', '#bbbbbb', '#e1e1d3', '#e1d5b1','#ccb77a','#ffffe5','#f7fcb9', '#addd8e', '#41ab5d', '#006837', '#004529'],
                    'fname'  : ['DEWPOINT_2M']},
  'q2inc'        :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['Q2'], 'filename':'incr', 'sfclevel':0 },
  'psfcinc'        :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['PSFC'], 'filename':'incr', 'sfclevel':0 },
  'heatindex'    :{ 'levels' : [65,70,75,80,85,90,95,100,105,110,115,120,125,130], 'cmap': readNCLcm('MPL_hot')[::-1], 'fname': ['AFWA_HEATIDX'], 'filename':'diag' },
#  'pblh'         :{ 'levels' : [0,250,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000], 'cmap': readNCLcm('precip2_17lev')[3:-1], 'fname': ['C_PBLH'], 'filename':'diag' },
  'pblh'         :{ 'levels' : [0,250,500,750,1000,1250,1500,1750,2000,2500,3000,3500,4000],
                    'cmap': ['#eeeeee', '#dddddd', '#cccccc', '#bbbbbb', '#44aaee','#88bbff', '#aaccff', '#bbddff', '#efd6c1', '#e5c1a1', '#eebb32', '#bb9918'], 'fname': ['PBLH'] },
  'hmuh'         :{ 'levels' : [10,25,50,75,100,125,150,175,200,250,300,400,500], 'cmap': readNCLcm('prcp_1')[:15], 'fname': ['UP_HELI_MAX'], 'filename':'diag'},
  'hmup'         :{ 'levels' : [4,6,8,10,12,14,16,18,20,24,28,32,36,40,44,48], 'cmap': readNCLcm('prcp_1')[1:16], 'fname': ['W_UP_MAX'], 'filename':'diag' },
  #'hmdn'         :{ 'levels' : [-19,-17,-15,-13,-11,-9,-7,-5,-3,-1,0], 'cmap': readNCLcm('prcp_1')[16:1:-1]+['#ffffff'], 'fname': ['W_DN_MAX'], 'filename':'diag' },
  'hmdn'         :{ 'levels' : [2,3,4,6,8,10,12,14,16,18,20,22,24,26,28,30], 'cmap': readNCLcm('prcp_1')[1:16], 'fname': ['W_DN_MAX'], 'filename':'diag' },
  'hmwind'       :{ 'levels' : [10,12,14,16,18,20,22,24,26,28,30,32,34], 'cmap': readNCLcm('prcp_1')[:15], 'fname': ['WSPD10MAX'], 'filename':'diag' },
  'hmgrp'        :{ 'levels' : [0.01,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,4.0,5.0], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['GRPL_MAX'], 'filename':'diag' },
# 'cref'         :{ 'levels' : [5,10,15,20,25,30,35,40,45,50,55,60,65,70], 'cmap': readcm('cmap_rad.rgb')[2:16], 'fname': ['REFL_10CM'], 'arraylevel':'max' },
  'cref'         :{ 'levels' : [5,10,15,20,25,30,35,40,45,50,55,60,65,70], 'cmap': readcm('cmap_rad.rgb')[0:13], 'fname': ['REFL_MAX_COL'], 'filename':'upp' },
  'refl'         :{ 'levels' : [5,10,15,20,25,30,35,40,45,50,55,60,65,70], 'cmap': readcm('cmap_rad.rgb')[1:14], 'fname': ['NCL_REFL'] },
  'lmlref'       :{ 'levels' : [5,10,15,20,25,30,35,40,45,50,55,60,65,70], 'cmap': readcm('cmap_rad.rgb')[1:14], 'fname': ['REFL_10CM'], 'arraylevel':0 },
  'ref1km'       :{ 'levels' : [5,10,15,20,25,30,35,40,45,50,55,60,65,70], 'cmap': readcm('cmap_rad.rgb')[1:14], 'fname': ['REFL_1KM_AGL'], 'filename':'upp' },
  'echotop'      :{ 'levels' : [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], 'cmap': readNCLcm('precip3_16lev'), 'fname': ['ECHOTOP'], 'filename':'diag' },
  'srh3'         :{ 'levels' : [50,100,150,200,250,300,400,500], 'cmap': readNCLcm('topo_15lev')[1:], 'fname': ['SR_HELICITY'], 'filename' : 'upp', 'arraylevel':1 },
  'srh1'         :{ 'levels' : [50,100,150,200,250,300,400,500], 'cmap': readNCLcm('topo_15lev')[1:], 'fname': ['SR_HELICITY'], 'filename' : 'upp', 'arraylevel':0 },
  'shr06mag'     :{ 'levels' : [30,35,40,45,50,55,60,65,70,75,80], 'cmap': readNCLcm('topo_15lev')[1:], 'fname': ['UBSHR6', 'VBSHR6'], 'filename':'upp' },
  'shr01mag'     :{ 'levels' : [10,15,20,25,30,35,40,45,50,55,60], 'cmap': readNCLcm('topo_15lev')[1:], 'fname': ['UBSHR1', 'VBSHR1'], 'filename':'upp' },
  'zlfc'         :{ 'levels' : [0,250,500,750,1000,1250,1500,2000,2500,3000,3500,4000,5000], 'cmap': [readNCLcm('nice_gfdl')[i] for i in [3,20,37,54,72,89,106,123,141,158,175,193]], 'fname': ['AFWA_ZLFC'], 'filename':'diag' },
  'zlcl'         :{ 'levels' : [0,250,500,750,1000,1250,1500,2000,2500,3000,3500,4000,5000], 'cmap': [readNCLcm('nice_gfdl')[i] for i in [3,20,37,54,72,89,106,123,141,158,175,193]], 'fname': ['LCL_HEIGHT'], 'filename':'upp' },
  'ltg1'         :{ 'levels' : [0.1,0.5,1,1.5,2,2.5,3,4,5,6,7,8,10,12], 'cmap': readNCLcm('prcp_1')[:15], 'fname': ['LTG1_MAX'], 'filename':'diag' },
  'ltg2'         :{ 'levels' : [0.1,0.5,1,1.5,2,2.5,3,4,5,6,7,8,10,12], 'cmap': readNCLcm('prcp_1')[:15], 'fname': ['LTG2_MAX'], 'filename':'diag' },
  'ltg3'         :{ 'levels' : [0.1,0.5,1,1.5,2,2.5,3,4,5,6,7,8,10,12], 'cmap': readNCLcm('prcp_1')[:15], 'fname': ['LTG3_MAX'], 'filename':'diag' },
  'liftidx'      :{ 'levels' : [-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8], 'cmap': readNCLcm('nice_gfdl')[193:3:-1]+['#ffffff'], 'fname': ['SFC_LI'], 'filename':'upp'},
  'bmin'         :{ 'levels' : [-20,-16,-12,-10,-8,-6,-4,-2,-1,-0.5,0,0.5], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['BMIN'], 'filename':'upp','arraylevel':0 },
  'goesch3'      :{ 'levels' : [-80,-78,-76,-74,-72,-70,-68,-66,-64,-62,-60,-58,-56,-54,-52,-50,-48,-46,-44,-42,-40,-38,-36,-34,-32,-30,-28,-26,-24,-22,-20,-18,-16,-14,-12,-10], 'cmap': readcm('cmap_sat2.rgb')[38:1:-1], 'fname': ['SBT123_GDS3_NTAT'], 'filename':'upp' },
  'goesch4'      :{ 'levels' : [-80,-76,-72,-68,-64,-60,-56,-52,-48,-44,-40,-36,-32,-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28,32,36,40], 'cmap': readcm('cmap_satir.rgb')[32:1:-1], 'fname': ['SBT124_GDS3_NTAT'], 'filename':'upp' },

  # winter fields
  'snow'         :{ 'levels' : [0.01,0.1,0.25,0.5,0.75,1,1.5,2,2.5,3,3.5,4], 'cmap':['#dddddd','#aaaaaa']+readNCLcm('precip3_16lev')[1:], 'fname':['SNOW_ACC_NC'], 'filename':'diag'},
  'snowacc'      :{ 'levels' : [0.01,0.1,0.5,1,2,3,4,5,6,8,10,12,18], 'cmap':['#dddddd','#aaaaaa']+readNCLcm('precip3_16lev')[1:], 'fname':['AFWA_SNOWFALL'], 'filename':'diag'},
# 'snowliq'      :{ 'levels' : [0.1,0.5,1,1.5,2,2.5,3,4,5,6], 'cmap':readNCLcm('precip3_16lev')[1:], 'fname':['AFWA_SNOW'], 'filename':'diag'},
  'iceacc'       :{ 'levels' : [0.01,0.05,0.1,0.15,0.2,0.25,0.3,0.4,0.5,1], 'cmap':readNCLcm('precip3_16lev')[1:], 'fname':['AFWA_ICE'], 'filename':'diag'},
  'fzraacc'      :{ 'levels' : [0.01,0.05,0.1,0.15,0.2,0.25,0.3,0.4,0.5,1], 'cmap':readNCLcm('precip3_16lev')[1:], 'fname':['AFWA_FZRA'], 'filename':'diag'},
  'windchill'    :{ 'levels' : [-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45], 'cmap':readNCLcm('GMT_ocean')[20:], 'fname':['AFWA_WCHILL'], 'filename':'diag'},
  'freezelev'    :{ 'levels' : [0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000], 'cmap':readNCLcm('nice_gfdl')[3:193], 'fname':['FZLEV'], 'filename':'diag'},

  # pressure level entries
  'hgt250'       :{ 'levels' : [9940,10000,10060,10120,10180,10240,10300,10360,10420,10480,10540,10600,10660,10720,10780,10840,10900,10960,11020], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['GEOP_HGT_PRS'], 'arraylevel':1 },
  'hgt300'       :{ 'levels' : [8700,8760,8820,8880,8940,9000,9060,9120,9180,9240,9300,9360,9420,9480,9540,9600,9660,9720,9780,9840,9900], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['GEOP_HGT_PRS'], 'arraylevel':2 },
  'hgt500'       :{ 'levels' : [5100,5160,5220,5280,5340,5400,5460,5520,5580,5640,5700,5760,5820,5880,5940,6000], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['GEOP_HGT_PRS'], 'arraylevel':3 },
  'hgt700'       :{ 'levels' : [2700,2730,2760,2790,2820,2850,2880,2910,2940,2970,3000,3060,3090,3120,3150,3180,3210,3240,3270,3300], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['GEOP_HGT_PRS'], 'arraylevel':4 },
  'hgt850'       :{ 'levels' : [1200,1230,1260,1290,1320,1350,1380,1410,1440,1470,1500,1530,1560,1590,1620,1650], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['GEOP_HGT_PRS'], 'arraylevel':5 },
  'hgt925'       :{ 'levels' : [550,580,610,640,670,700,730,760,790,820,850,880,910,940,1000,1030], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['GEOP_HGT_PRS'], 'arraylevel':6 },
  'speed250'     :{ 'levels' : [10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170], 'cmap': readNCLcm('wind_17lev'), 'fname': ['S_PL'], 'filename':'diag', 'arraylevel':8 },
  'speed300'     :{ 'levels' : [10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170], 'cmap': readNCLcm('wind_17lev'), 'fname': ['S_PL'], 'filename':'diag', 'arraylevel':7 },
  'speed500'     :{ 'levels' : [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85], 'cmap': readNCLcm('wind_17lev'), 'fname': ['S_PL'], 'filename':'diag', 'arraylevel':5 },
  'speed700'     :{ 'levels' : [4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68], 'cmap': readNCLcm('wind_17lev'), 'fname': ['S_PL'], 'filename':'diag', 'arraylevel':3 },
  'speed850'     :{ 'levels' : [3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51], 'cmap': readNCLcm('wind_17lev'), 'fname': ['S_PL'], 'filename':'diag', 'arraylevel':2 },
  'speed925'     :{ 'levels' : [3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51], 'cmap': readNCLcm('wind_17lev'), 'fname': ['S_PL'], 'filename':'diag', 'arraylevel':1 },
  'temp250'      :{ 'levels' : [-65,-63,-61,-59,-57,-55,-53,-51,-49,-47,-45,-43,-41,-39,-37,-35,-33,-31,-29], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['TEMP_PRS'], 'arraylevel':1 },
  'temp300'      :{ 'levels' : [-65,-63,-61,-59,-57,-55,-53,-51,-49,-47,-45,-43,-41,-39,-37,-35,-33,-31,-29], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['TEMP_PRS'], 'arraylevel':2 },
  'temp500'      :{ 'levels' : [-41,-39,-37,-35,-33,-31,-29,-26,-23,-20,-17,-14,-11,-8,-5,-2], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['TEMP_PRS'], 'arraylevel':3 },
  'temp700'      :{ 'levels' : [-36,-33,-30,-27,-24,-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['TEMP_PRS'], 'arraylevel':4 },
  'temp850'      :{ 'levels' : [-30,-27,-24,-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21,24,27,30], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['TEMP_PRS'], 'arraylevel':5 },
  'temp925'      :{ 'levels' : [-24,-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21,24,27,30,33], 'cmap': readNCLcm('nice_gfdl')[3:193], 'fname': ['TEMP_PRS'], 'arraylevel':1 },
  #'td300'        :{ 'levels' : [-65,-60,-55,-50,-45,-40,-35,-30], 'cmap' : readNCLcm('nice_gfdl'), 'fname': ['TD_PL'], 'filename':'diag', 'arraylevel':7 },
  #'td500'        :{ 'levels' : [-50,-45,-40,-35,-30,-25,-20,-15,-10], 'cmap' : readNCLcm('nice_gfdl'), 'fname': ['TD_PL'], 'filename':'diag', 'arraylevel':5 },
  'td700'        :{ 'levels' : [-30,-25,-20,-15,-10,-5,0,5,10], 'cmap' : readNCLcm('nice_gfdl')[3:193], 'fname': ['DEWPOINT_PRS'], 'arraylevel':4 },
  'td850'        :{ 'levels' : [-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30], 'cmap' : readNCLcm('nice_gfdl')[3:193], 'fname': ['DEWPOINT_PRS'], 'arraylevel':5 },
  'td925'        :{ 'levels' : [-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30], 'cmap' : readNCLcm('nice_gfdl')[3:193], 'fname': ['DEWPOINT_PRS'], 'arraylevel':6 },
  'rh300'        :{ 'levels' : [0,10,20,30,40,50,60,70,80,90,100], 'cmap' : [readNCLcm('MPL_PuOr')[i] for i in (2,18,34,50)]+[readNCLcm('MPL_Greens')[j] for j in (2,17,50,75,106,125)], 'fname': ['RH_PL'], 'filename':'diag', 'arraylevel':7 },
  'rh500'        :{ 'levels' : [0,10,20,30,40,50,60,70,80,90,100], 'cmap' : [readNCLcm('MPL_PuOr')[i] for i in (2,18,34,50)]+[readNCLcm('MPL_Greens')[j] for j in (2,17,50,75,106,125)], 'fname': ['RH_PL'], 'filename':'diag', 'arraylevel':5 },
  'rh700'        :{ 'levels' : [0,10,20,30,40,50,60,70,80,90,100], 'cmap' : [readNCLcm('MPL_PuOr')[i] for i in (2,18,34,50)]+[readNCLcm('MPL_Greens')[j] for j in (2,17,50,75,106,125)], 'fname': ['RH_PL'], 'filename':'diag', 'arraylevel':3 },
  'rh850'        :{ 'levels' : [0,10,20,30,40,50,60,70,80,90,100], 'cmap' : [readNCLcm('MPL_PuOr')[i] for i in (2,18,34,50)]+[readNCLcm('MPL_Greens')[j] for j in (2,17,50,75,106,125)], 'fname': ['RH_PL'], 'filename':'diag', 'arraylevel':2 },
  'rh925'        :{ 'levels' : [0,10,20,30,40,50,60,70,80,90,100], 'cmap' : [readNCLcm('MPL_PuOr')[i] for i in (2,18,34,50)]+[readNCLcm('MPL_Greens')[j] for j in (2,17,50,75,106,125)], 'fname': ['RH_PL'], 'filename':'diag', 'arraylevel':1 },
  'avo500'       :{ 'levels' : [0,9,12,15,18,21,24,27,30,33], 'cmap': readNCLcm('prcp_1'), 'fname': ['ABS_VORT_PRS'], 'arraylevel':3 },
  'iso300'       :{ 'levels' : [10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170], 'cmap':readNCLcm('wind_17lev'), 'fname':['U_GRID_PRS', 'V_GRID_PRS'],'arraylevel':2 },
  'iso500'       :{ 'levels' : [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85], 'cmap':readNCLcm('wind_17lev'), 'fname':['U_GRID_PRS', 'V_GRID_PRS'],'arraylevel':3 },
  'iso700'       :{ 'levels' : [4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68], 'cmap':readNCLcm('wind_17lev'), 'fname':['U_GRID_PRS', 'V_GRID_PRS'],'arraylevel':4 },
  'iso850'       :{ 'levels' : [3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51], 'cmap':readNCLcm('wind_17lev'), 'fname':['U_GRID_PRS', 'V_GRID_PRS'],'arraylevel':5 },
'pvort320k'    :{ 'levels' : [0,0.1,0.2,0.3,0.4,0.5,0.75,1,1.5,2,3,4,5,7,10],
                  'cmap'   : ['#ffffff','#eeeeee','#dddddd','#cccccc','#bbbbbb','#d1c5b1','#e1d5b9','#f1ead3','#003399','#0033FF','#0099FF','#00CCFF','#8866FF','#9933FF','#660099'],
                 'fname': ['PVORT_320K'], 'filename':'upp' },
 'bunkmag'      :{ 'levels' : [20,25,30,35,40,45,50,55,60], 'cmap':readNCLcm('wind_17lev'), 'fname':['U_COMP_STM', 'V_COMP_STM'], 'filename':'upp' },
  #'stp'         :{ 'levels' : [0.5,0.75,1.0,1.5,2.0,3.0,4.0,5.0,7.5,10.0], 'cmap':readNCLcm('prcp_1'), 'fname':['SBCAPE','LCL_HEIGHT','SR_HELICITY','UBSHR6','VBSHR6'], 'filename':'upp'}
  #'sigsvr       :{ 'levels' : [1e5,2e5,3e5,4e5,5e5,6e5,8e5,10e5], 'cmap':readNCLcm('prcp_1'), 'fname':['MLCAPE','UHSHR], 'filename':'upp'}
  'qvl0inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['QVAPOR'], 'filename':'incr', 'arraylevel':0 },
  'qvl5inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['QVAPOR'], 'filename':'incr', 'arraylevel':5 },
  'qvl10inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['QVAPOR'], 'filename':'incr', 'arraylevel':10 },
  'templ0inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':0 },
  'templ5inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':5 },
  'templ10inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':10 },
  'templ15inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':15 },
  'templ20inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':20 },
  'templ25inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':25 },
  'templ30inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':30 },
#  'templ35inc'     :{ 'levels' : [-2.5,-2.25,-2,-1.75,-1.5,-1.25,-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':35 },
  'templ35inc'     :{ 'levels' : [-5.0,-3.5,-3.0,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3.0,3.5], 'cmap': readNCLcm('BlueDarkRed18')[1:], 'fname': ['T'], 'filename':'incr', 'arraylevel':35 },

  # wind barb entries
  'wind10m'      :{ 'fname'  : ['U10', 'V10'], 'skip':10 },
  'wind10m-inc'  :{ 'fname'  : ['U10', 'V10'], 'filename':'incr', 'skip':10 },
  'windl0-inc'   :{ 'fname'  : ['U', 'V'], 'arraylevel':0, 'filename':'incr', 'skip':10 },
  'windl5-inc'   :{ 'fname'  : ['U', 'V'], 'arraylevel':5, 'filename':'incr', 'skip':10 },
  'windl10-inc'  :{ 'fname'  : ['U', 'V'], 'arraylevel':10, 'filename':'incr', 'skip':10 },
  'windl15-inc'  :{ 'fname'  : ['U', 'V'], 'arraylevel':15, 'filename':'incr', 'skip':10 },
  'windl20-inc'  :{ 'fname'  : ['U', 'V'], 'arraylevel':20, 'filename':'incr', 'skip':10 },
  'windl25-inc'  :{ 'fname'  : ['U', 'V'], 'arraylevel':25, 'filename':'incr', 'skip':10 },
  'windl30-inc'  :{ 'fname'  : ['U', 'V'], 'arraylevel':30, 'filename':'incr', 'skip':10 },
  'windl35-inc'  :{ 'fname'  : ['U', 'V'], 'arraylevel':35, 'filename':'incr', 'skip':10 },
  'windl0'       :{ 'fname'  : ['U_LEV1', 'V_LEV1'], 'skip':10 },
  'wind250'      :{ 'fname'  : ['U_GRID_PRS', 'V_GRID_PRS'], 'arraylevel':1, 'skip':10 },
  'wind300'      :{ 'fname'  : ['U_GRID_PRS', 'V_GRID_PRS'], 'arraylevel':2, 'skip':10 },
  'wind500'      :{ 'fname'  : ['U_GRID_PRS', 'V_GRID_PRS'], 'arraylevel':3, 'skip':10 },
  'wind700'      :{ 'fname'  : ['U_GRID_PRS', 'V_GRID_PRS'], 'arraylevel':4, 'skip':10 },
  'wind850'      :{ 'fname'  : ['U_GRID_PRS', 'V_GRID_PRS'], 'arraylevel':5, 'skip':10 },
  'wind925'      :{ 'fname'  : ['U_GRID_PRS', 'V_GRID_PRS'], 'arraylevel':6, 'skip':10 },
  'shr06'        :{ 'fname'  : ['UBSHR6','VBSHR6'], 'filename': 'upp', 'skip':40 },
  'shr01'        :{ 'fname'  : ['UBSHR1', 'VBSHR1'], 'filename': 'upp', 'skip':40 },
  'bunkers'      :{ 'fname'  : ['U_COMP_STM', 'V_COMP_STM'], 'filename': 'upp', 'skip':40 },
}

# domains = { 'domainname': { 'corners':[ll_lat,ll_lon,ur_lat,ur_lon], 'figsize':[w,h] } }
domains = { 'ANLYS' :{ 'corners': [13.69,-127.749,53.2775,-53.4528], 'fig_width': 1080 },
            'CONUS' :{ 'corners': [23.1593,-120.811,46.8857,-65.0212], 'fig_width': 1080 }
}
