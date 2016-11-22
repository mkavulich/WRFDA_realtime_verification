 &userin
 idotitle=1,titlecolor='def.foreground',
 title='15km ARW WRF, NAM-init -- NCAR/MMM',
 ptimes=PTIMES
 ptimeunits='h',tacc=600,timezone=-7,iusdaylightrule=1,
 iinittime=1,ivalidtime=1,inearesth=1,
 flmin=.04, frmax=.95, fbmin=.06, ftmax=.84,
 ntextq=0,ntextcd=1,ntextfn=4,mdatebf=99999999,
 idescriptive=1,icgmsplit=0,maxfld=10,itrajcalc=0,imakev5d=0
 /
 &trajcalc
 rtim=24,ctim=6,dtfile=10800.,dttraj=600.,vctraj='s',
 xjtraj=25,20,15,10,35,70,65,40.6,40.6,40.6,40.6,40.6,40.6,
 yitraj=50,55,60,65,70,65,20,37,37,37,37,37,37,
 zktraj=.9,.9,.9,.9,.9,.9,.9,.99,.9,.8,.7,.6,.5, 
 ihydrometeor=0
 /
===========================================================================
----------------------    Plot Specification Table    ---------------------
===========================================================================
feld=tsff; ptyp=hc; cmth=fill; colr=blue; cint=5.; vcor=s; levs=1fb; smth=101;> 
 cosq=-62,white,-42.,dark.gray,-22.,magenta,-12.,light.violet,-2.,violet,2.,med.gray,>
#12.,light.violet,22.,light.blue,32.,surf.green,>
#42.,light.green,52.,parchment,62.,light.orange,72.,med.red,82.,peach,92,light.gray,>
 12.,light.violet,22.,light.blue,32.,surf.green,>
 42.,forest.green,52.,parchment,62.,light.orange,72.,med.red,82.,peach,92,light.gray,>
 102,dark.red,122.,brown
feld=slpgr; ptyp=hc; linw=2; cint=4; colr=very.dark.blue; smth=104; mjsk=1;>
 tslb=.010; tshl=.014; pwhl=0
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
  vcor=s; levs=1fb; linw=1; smth=0; intv=9; colr=black 
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=LANDMASK; ptyp=hc; cmth=fill; cbeg=0.1; cint=20.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,very.light.blue,0.1,very.light.blue,.5,wheat1
feld=ter; ptyp=hc; cmth=fill; colr=black; cbeg=0.1; cint=200.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,transparent,500,transparent,600,wheat1,1000.,wheat2,1600.,wheat3,2600,wheat4,3800.,white
feld=rhu; ptyp=hc; cmth=fill; cint=10.; vcor=p;>
  cbeg=10.; cend=100.; smth=101; levs=850.; colr=dark.green;>
  cosq=26.,transparent,49.,white,50.,surf.green,60.,light.green,80.,green,>
  90.,dark.green,98.,dark.green,99.,yellow,100.,yellow
feld=tmc; ptyp=hc; linw=2; cint=5; vcor=p; levs=850.; colr=dark.red;>
 smth=101; tslb=.014; mjsk=1; pwlb=0.
feld=ght; ptyp=hc; linw=3; cint=20; colr=dark.blue; smth=105;>
   vcor=p; levs=850; tslb=.012; mjsk=1
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
   vcor=p; levs=850.; linw=1; smth=101; intv=11; colr=med.gray
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=LANDMASK; ptyp=hc; cmth=fill; cbeg=0.1; cint=20.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,very.light.blue,0.1,very.light.blue,.5,wheat1
feld=ter; ptyp=hc; cmth=fill; colr=black; cbeg=0.1; cint=200.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,transparent,500,transparent,600,wheat1,1000.,wheat2,1600.,wheat3,2600,wheat4,3800.,white
feld=www; ptyp=hc; cmth=fill; vcor=p; colr=black;>
 levs=700; smth=0; tslb=.012; mjsk=0; cint=5; cbeg=-30.; cend=60.;>
 cosq=-30.,light.blue,-20.,violet,-10.,light.violet,-4.,white,0.,transparent,4.,>
      white,10.,light.green,20.,green,30.,yellow,40.,orange,50.,red,60.,dark.red
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
 vcor=p; levs=700.; linw=1; smth=101; intv=11; colr=med.gray
feld=tmc; ptyp=hc; linw=2; cint=5; vcor=p; levs=700.; colr=dark.red;>
 smth=102; tslb=.013; mjsk=0; pwlb=0.
feld=ght; ptyp=hc; linw=3; cint=30; colr=dark.blue; smth=104;>
 vcor=p; levs=700; tslb=.012; mjsk=0; tshl=.015; pwlb=0
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
# Note: can't overlay cell plots. Must use fill.
feld=ter; ptyp=hc; cmth=fill; colr=black; cbeg=0.1; cint=200.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,very.light.blue,0.1,very.light.blue,100.,wheat1,600,wheat1,1000.,wheat2,>
 1600.,wheat3,2600,wheat4,3800.,white
feld=avo; ptyp=hc; cmth=fill; cint=5.; smth=102.; levs=500.;>
 vcor=p; tslb=.012; cbeg=-30; cend=60;>
 cosq=-35.,blue,-10.,very.light.blue,-5.,transparent,5.,transparent,>
 10.,very.light.red,40.,red,45.,dark.red,50.,light.yellow,60,yellow
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
 vcor=p; levs=500.; linw=1; smth=101; intv=11; colr=med.gray
feld=tmc; ptyp=hc; linw=2; cint=5; vcor=p; levs=500.; colr=dark.red;>
 smth=102; tslb=.013; mjsk=0; pwlb=0.; nohl
feld=ght; ptyp=hc; linw=3; cint=60; colr=dark.blue; smth=104;>
 vcor=p; levs=500; tslb=.012; tshl=.015; mjsk=0; pwlb=0
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=ter; ptyp=hc; cmth=fill; colr=black; cbeg=0.1; cint=200.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,very.light.blue,0.1,very.light.blue,100.,wheat1,600,wheat1,1000.,wheat2,1600.,wheat3,2600,wheat4,3800.,white
feld=wsp; ptyp=hc; cmth=fill; cint=10.; vcor=p; colr=violet; nobr;>
 levs=300.; cbeg=40.; cend=100.; smth=101;>
 cosq=0.,transparent,30.,transparent,40.,light.violet,100.,dark.violet
feld=pvo; ptyp=hc; cmth=fill; cint=1.; colr=black; vcor=p;>
 levs=300.; cbeg=0.; cend=5.; smth=101;>
 cosq=-8.,dark.red,-1.,red,.0,white,0.3,transparent,1.,transparent,2.,>
 very.light.gray,3.,light.gray,4.,med.gray,5.,dark.gray
feld=wsp; ptyp=hc; vcor=p; levs=300.; cbeg=20.; cint=10.; linw=2;>
  colr=dark.violet; pwhl=0.; smth=101.; mjsk=0; nohl; tslb=.015; pwlb=0; nttl
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
 vcor=p; levs=300.; linw=1; smth=101; intv=11; colr=med.gray
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=ter; ptyp=hc; cmth=fill; colr=black; cbeg=0.1; cend=200.; cint=100.; vcor=s;>
 levs=1fb; nttl; nobr; nmsg; hvbr=0;>
 cosq=-50.,powder.blue,0.1,powder.blue,10.,peach
feld=wsp; ptyp=hc; vcor=p; levs=150.; cbeg=20.; cend=80; cint=5.;>
 cmth=fill; smth=101;>
 cosq=-.5,transparent,19.,transparent,19.9,parchment,30.,light.yellow,40.,yellow,50.,gold,60.,dark.yellow,70.,white
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
 vcor=p; levs=150.; linw=1; smth=101; intv=13; colr=black
feld=tmc; ptyp=hc; linw=2; cint=5; vcor=p; levs=150; colr=dark.red;>
 smth=101; tslb=.013; mjsk=0; pwlb=0.
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=ter; ptyp=hc; cmth=fill; colr=black; cbeg=0.1; cend=200.; cint=100.; vcor=s;>
 levs=1fb; nttl; nobr; nmsg; hvbr=0;>
 cosq=-50.,powder.blue,0.1,powder.blue,10.,peach
feld=wsp; ptyp=hc; vcor=s; levs=1; cbeg=20.; cend=80; cint=5.;>
 cmth=fill; smth=101;>
 cosq=-.5,transparent,19.,transparent,19.9,parchment,30.,light.yellow,40.,yellow,50.,gold,60.,dark.yellow,70.,white
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
 vcor=s; levs=1; linw=1; smth=101; intv=13; colr=black
feld=tmc; ptyp=hc; linw=2; cint=5; vcor=s; levs=1; colr=dark.red;>
 smth=101; tslb=.013; mjsk=0; pwlb=0.
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=rhu; ptyp=hc; cmth=cell; cint=10.; vcor=s;>
  cbeg=20.; cend=100.;>
  cosq=20.,white,40.,light.green,60.,green,80.,forest.green,100.,dark.green;>
  smth=101; levs=7fb
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
   vcor=s; levs=7fb; linw=1; smth=101; intv=9; colr=black
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
# 3-h total precip. Uses modified version of fields which has separate totals
# for snow (stot), and mixed (mtot) precip. Intersecting regions are muddied because
# contouring has to start at zero (whiteish). Setting the array to missing (rmsg) causes
# too many cells to be omitted. This is the best compromise
feld=LANDMASK; ptyp=hc; cmth=fill; cbeg=0.1; cint=20.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,very.light.blue,0.1,very.light.blue,.5,wheat1
feld=ter; ptyp=hc; cmth=fill; colr=black; cbeg=0.1; cint=200.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,transparent,500,transparent,600,wheat1,1000.,wheat2,1600.,wheat3,2600,wheat4,3800.,white
feld=rtot3h; ptyp=hc; cmth=fill; cbeg=0.1; cend=400.; cint=2.; mult;>
cosq=-.5,transparent,.08,transparent,.09,white,.8,light.green,3.2,green,9.99,dark.green,10.,yellow,>
24.99,yellow,25.,orange,51.1,orange,51.2,red,102.3,red,102.4,violet,204.7,violet,204.8,white
feld=stot3h; ptyp=hc; cmth=fill; cbeg=0.1; cend=400.; cint=2.; mult; nobr; nttl; nmsg;>
cosq=-.5,transparent,.08,transparent,.09,white,.8,very.light.blue,3.2,light.blue,9.99,blue,10.,yellow,>
24.99,yellow,25.,orange,51.1,orange,51.2,red,102.3,red,102.4,violet,204.7,violet,204.8,white
feld=mtot3h; ptyp=hc; cmth=fill; cbeg=0.2; cend=400.; cint=2.; mult; nobr; nttl; nmsg;>
cosq=-.5,transparent,.08,transparent,.39,transparent,.40,very.light.magenta,9.99,magenta,10.,yellow,>
24.99,yellow,25.,orange,51.1,orange,51.2,red,102.3,red,102.4,violet,204.7,violet,204.8,white
feld=rtot3h; ptyp=hc; linw=1; mult; cbeg=200.; cint=2.; colr=black;>
 levs=1fb; smth=0; mjsk=4; pwhl=0.; nohl=L; nttl; nmsg
feld=slpgr; ptyp=hc; linw=1; cint=2; colr=light.blue; smth=105; tslb=.011; pwhl=0.
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=LANDMASK; ptyp=hc; cmth=fill; cbeg=0.1; cint=20.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,very.light.blue,0.1,very.light.blue,.5,wheat1
feld=ter; ptyp=hc; cmth=fill; colr=black; cbeg=0.1; cint=200.; vcor=s; levs=1fb; nttl; nobr;>
 cosq=-50.,transparent,500,transparent,600,wheat1,1000.,wheat2,1600.,wheat3,2600,wheat4,3800.,white
feld=rtotsh0; ptyp=hc; cmth=fill; cbeg=0.1; cend=400.; cint=2.; mult;>
cosq=-.5,transparent,.08,transparent,.09,white,.8,light.green,3.2,green,9.99,dark.green,10.,yellow,>
24.99,yellow,25.,orange,51.1,orange,51.2,red,102.3,red,102.4,violet,204.7,violet,204.8,white
feld=rtotsh0; ptyp=hc; linw=1; mult; cbeg=200.; cint=2.; colr=black;>
 levs=1fb; smth=0; mjsk=4; pwhl=0.; nohl=L; nttl; nmsg
#feld=slpgr; ptyp=hc; linw=1; cint=2; colr=light.blue; smth=105; tslb=.011
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=rhu; ptyp=vc; cmth=fill; cint=10.; vcor=p;>
  cosq=20.,white,40.,light.green,60.,green,80.,dark.green;>
  smth=101; crsa=KGJT; crsb=KMCK
feld=the; ptyp=vc; vcor=p; cint=3.; linw=2;>
 colr=black; tslb=.012; crsa=KGJT; crsb=KMCK
feld=uuu,vvv,omg; ptyp=vv; vcor=p; vvnx=30; vcmx=20;>
  colr=black; crsa=KGJT; crsb=KMCK
feld=tic; ptyp=vb; axld=500.; axtd=20; axtv=10
===========================================================================
feld=qsn; ptyp=vc; cmth=fill; cint=0.; vcor=p; cbeg=.0;>
 arng; cosq=10,white,33,light.gray,67,med.gray,100,dark.gray;>
  smth=101; crsa=KGJT; crsb=KMCK
feld=tmc; ptyp=vc; vcor=p; cint=5.; linw=2;>
  colr=black; mjsk=1; crsa=KGJT; crsb=KMCK
feld=qra; ptyp=vc; vcor=p; linw=2; dash=32;>
 cbeg=.0; cint=.1;>
  colr=red ; crsa=KGJT; crsb=KMCK
feld=qcw; ptyp=vc; vcor=p; linw=2; dash=32;>
 cbeg=.0; cint=.1;>
  colr=blue; crsa=KGJT; crsb=KMCK
feld=qci; ptyp=vc; vcor=p; cint=0.; linw=2; dash=32;>
  colr=dark.green; cbeg=.0; cint=.1; crsa=KGJT; crsb=KMCK
feld=tic; ptyp=vb; axld=500.; axtd=20; axtv=10
===========================================================================
feld=mcap; ptyp=hc; cmth=cell; cint=250.; vcor=s; >
 save; levs=1fb; cbeg=250.; cend=6000.; smth=0;> 
# cosq=-500.,white,249.,white,500.,light.gray,999.,light.gray,1000.,light.blue,1499.,light.blue,1500.,blue,>
#      1999.,blue,2000.,orange,2499.,orange,2500.,light.red,2999.,light.red,3000.,red,4000,dark.red,6000.,violet
 cosq=-500.,white,249.,white,500.,light.gray,999.,light.gray,1000.,light.blue,1499.,>
 light.blue,1500.,blue,1999.,blue,2000.,orange,2499.,orange,2500.,light.red,2999.,>
 light.red,3000.,red,3499,red,3500,yellow,3999,yellow,>
 4000,wheat0,4999,dark.red,5000.,violet,5999,white
feld=uubs,vvbs; ptyp=hv; vcmx=-15; fulb=10kts;>
   vcor=s; levs=1fb; linw=1; smth=0; intv=11; colr=black 
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=intcld; ptyp=hc; vcor=s; colr=blue; linw=2;>
 cmth=fill; cbeg=.01; cend=10.; cint=5; mult;>
 levs=1fb; nsmm; smth=101; mjsk=0;>
 cosq=-.5,white,.009,white,.02,very.light.blue,.25,light.blue,6.25,blue,20,violet
feld=intpcp; ptyp=hc; vcor=s; colr=red; linw=1; nohl;>
 levs=1fb; cbeg=.1; cint=3; mult; nsmm; smth=101; mjsk=0
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=rcum3h; ptyp=hc; cmth=fill; cbeg=0.1; cint=2.; mult; cend=204.8; colr=dark.blue;>
cosq=-.5,transparent,.09,white,.8,very.light.blue,3.2,light.blue,9.99,blue,10.,very.light.red,24.99,very.light.red,25.,red.coral,51.1,red.coral,51.2,light.gray,102.3,light.gray,102.4,dark.gray,204.7,dark.gray,204.8,light.purple
feld=rexp3h; ptyp=hc; vcor=s; colr=red; linw=1; nohl;>
 levs=1fb; cbeg=.1; cint=4; mult; nsmm; smth=0; mjsk=0
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=tdsff; ptyp=hc; cmth=cell; colr=blue; cint=5.; vcor=s; levs=1fb; smth=101;>
 cosq=-62,white,-42.,dark.gray,-22.,magenta,-12.,light.violet,-2.,violet,2.,med.gray,>
  12.,light.violet,22.,light.blue,32.,surf.green,>
  42.,forest.green,52.,parchment,62.,light.orange,72.,med.red,82.,peach,92,light.gray,>
  102,dark.red,122.,brown
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
 vcor=s; levs=1fb; linw=1; smth=0; intv=9; colr=black
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=bsh1k; ptyp=hc; cmth=fill; vcor=s; levs=1fb; cbeg=10.; cint=5.;>
 pwhl=0.; smth=101.; nohl; colr=dark.blue;>
 cosq=-1.,white,10.,white,15.,very.light.blue,25.,light.blue,50.,blue
feld=bsh1k; ptyp=hc; levs=1fb; cint=5.; linw=1; cbeg=10.;>
   colr=dark.blue; pwlb=0.; smth=101; mjsk=1; nohl; tslb=.009; nttl; nmsg
feld=ehi1; ptyp=hc; levs=1fb; cint=2.; mult; linw=2; cbeg=1.;>
   colr=dark.red; pwhl=0.; smth=101; mjsk=0; nohl; tslb=.011
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=vgp; ptyp=hc; cmth=cell; cbeg=0.1; cend=0.8; cint=.1; smth=0.;>
cosq=-.5,white,.09,white,.1,light.green,.19,light.green,.2,yellow,.29,yellow,.3,orange,.39,orange,.4,>
  red,.49,red,.5,violet,.59,violet,.6,light.blue,.69,light.blue,.7,white
feld=vgp; ptyp=hc; levs=1fb; cbeg=0.1; cend=0.8; cint=.1; linw=1;>
 colr=black; pwhl=0.; smth=0; mjsk=0; tslb=.011; nohl; nolb; nttl
feld=rcum3h; ptyp=hc; vcor=s; colr=dark.red; linw=1;>
 levs=1fb; mult; cbeg=.1; cint=4; mjsk=0; pwhl=0.; tslb=.010
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=sr9; ptyp=hc; cmth=fill; cint=2.; vcor=s;>
 levs=1fb; cbeg=0.; smth=104;>
 cosq=0.,white,12.,white,12.,light.green,18.,light.green,18.,light.blue,28.,light.blue,28.,orange
feld=uusr,vvsr; ptyp=hv; vcmx=-15; fulb=10kts;>
 vcor=s; levs=1fb; linw=1; smth=0; intv=9; colr=black
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=srfh; ptyp=hc; cmth=fill; levs=1fb; cint=5.; linw=2; cbeg=5.;>
 smth=104; cend=25.;>
 cosq=0,white,5,white,10,light.gray,15,light.blue,20,med.gray,25,blue
feld=srfl; ptyp=hc; levs=1fb; cint=5.; linw=2; cbeg=10.;>
   colr=red; pwhl=0.; smth=104; mjsk=0; tslb=.014
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=mcin; ptyp=hc; cmth=cell; cint=25.; vcor=s; save;>
# smoothing the mcin field is not a good idea
 levs=1fb; cbeg=-25.; cend=150.; smth=0;>
 cosq=-200.,white,-.01,white,0.,red,25.,red,50.,blue,75.,light.blue,100.,light.gray,125.,wheat1
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=50; axtg=5
===========================================================================
feld=bsh3k; ptyp=hc; cmth=cell; vcor=s; levs=1fb; cbeg=10.; cend=60.; cint=5.;>
 pwhl=0.; smth=101.; nohl;>
 cosq=-1.,white,10.,white,15.,very.light.blue,60.,light.blue
#feld=bsh3k; ptyp=hc; levs=1fb; cint=5.; linw=1; cbeg=10.;>
#   colr=dark.blue; pwlb=0.; smth=101; mjsk=1; nohl; tslb=.009; nttl
feld=uubs3,vvbs3; ptyp=hv; vcmx=-15; fulb=10kts;>
   vcor=s; levs=1fb; linw=1; smth=101; intv=9; colr=black
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=SNOWH; ptyp=hc; cmth=fill; cbeg=0.001; cint=2; mult;>
cosq=-.5,white,.0009,white,.008,light.purple,.032,light.blue,.0999,blue,.10,yellow,.2499,yellow,.25,orange,.511,orange,.512,red,1.023,red,1.024,violet,2.047,violet,2.048,white
feld=SNOWH; ptyp=hc; linw=1; mult; cbeg=200.; cint=2.; colr=black;>
 levs=1; smth=0; mjsk=4; nttl; pwhl=0.
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=maxdbz; ptyp=hc; cmth=fill; cbeg=0.; cend=75.; cint=5.; levs=1fb; save; >
  cosq=0,white,5,white,10,cyan,15.,light.blue,20,blue,>
  25,light.green,30.,green,35.,dark.green,35.,yellow,40.,light.orange,>
  45.,orange,50.,red,55.,med.red,60.,dark.red,65.,light.violet,70.,violet,75.,white
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=lfc; ptyp=hc; vcor=s; levs=1fb; cint=400.; cbeg=200.; cend=4000.; cmth=cell; smth=101;>
 cosq=0,red,400.,red,800.,orange,1200.,yellow,1600.,green,2000.,med.gray,4000.,white; nohl; nolb
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=50; axtg=5
===========================================================================
feld=lcl; ptyp=hc; vcor=s; levs=1fb; cint=400.; cbeg=200.; cend=4000.; cmth=cell; smth=101; >
 cosq=0,red,400.,red,800.,orange,1200.,yellow,1600.,green,2000.,med.gray,4000.,white; nohl; nolb
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
# Transparent color requires the fill method
feld=qcl; ptyp=hc; vcor=s; levs=13,-3; cint=.02; cbeg=0.01; cmth=fill; colr=blue; smth=102;>
 cosq=0,transparent,.0099,transparent,.01,light.blue,.5,blue; nohl; nolb; nobr
feld=qcl; ptyp=hc; vcor=s; levs=18,-14; cint=.01; cbeg=0.01; cmth=fill; colr=dark.yellow; smth=102;>
 cosq=0,transparent,.0099,transparent,.01,light.yellow,.5,yellow; nohl; nolb; nobr
feld=qcl; ptyp=hc; vcor=s; levs=23,-19; cint=.02; cbeg=0.01; cmth=fill; colr=light.violet; smth=102;>
 cosq=0,transparent,.0099,transparent,.01,light.violet,.5,violet; nohl; nolb; nobr
feld=qcl; ptyp=hc; vcor=s; levs=30,-24; cint=.02; cbeg=0.01; cmth=fill; smth=102;>
 cosq=0,transparent,.0099,transparent,.01,light.gray,.5,dark.gray; nohl; nolb; nobr
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=thck100050; ptyp=hc; cmth=cell; cint=6.; vcor=p; smth=102;>
 cbeg=480.; cend=600.;>
 cosq=480.,white,504.,dark.blue,516.,magenta,534.,light.blue,546.,light.green,558.,>
   light.yellow,564.,light.orange,576.,med.red,588.,dark.red,600.,brown
feld=thck100050; ptyp=hc; vcor=p; cint=12.; linw=1;>
   colr=dark.blue; pwhl=0.; smth=102.; mjsk=0; nohl; tslb=.014; nttl
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=eth; ptyp=hc; cmth=cell; colr=blue; cint=5.; vcor=s; levs=1fb;> 
 cbeg=270.; cend=360.; smth=102; >
 cosq=250.,white,260.,magenta,270.,light.violet,280.,light.blue,290.,surf.green,>
      300.,light.green,310.,light.yellow,320.,light.orange,330.,med.red,340.,peach,350.,light.gray,360.,white
#feld=eth; ptyp=hc; linw=1; cint=5; colr=black; smth=102; mjsk=1; tslb=.012; nohl
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=wsp; ptyp=hc; cmth=cell; cint=3.; cbeg=6.; cend=60.; vcor=s; levs=1fb; smth=101;>
 cosq=-1.,white,5.9,white,14.3,med.gray,14.4,light.green,19.3,light.green,19.4,dark.green,>
     28.8,dark.green,28.9,yellow,32.9,yellow,33.,orange,42.9,orange,43.,dark.red,49.5,dark.red,>
     50.,light.red,58.5,light.red
feld=uuu,vvv; ptyp=hv; vcmx=-15; fulb=10kts;>
  vcor=s; levs=1fb; linw=1; smth=101; intv=9; colr=black 
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=pcpw; ptyp=hc; cmth=cell; cint=5; cbeg=0.; cend=100.; vcor=s; smth=101; >
 cosq=0.,white,25.,light.gray,50.,green,75.,dark.green,100.,violet;>
  levs=1fb; hvbr=0
feld=pcpw; ptyp=hc; linw=1; mult; cbeg=10; cint=10.; colr=black;>
  levs=1fb; nsmm; smth=101; mjsk= 0;  pwhl=0.; pwlb=0.; tslb=.007; nohl; nmsg; nttl
feld=pcpw; ptyp=hc; linw=1; cbeg=50; cend=50.; colr=black;>
  levs=1fb; nsmm; smth=101; mjsk= 0;  pwhl=0.; pwlb=0.; tslb=.007; nohl; nmsg; nttl
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=ctt; ptyp=hc; cmth=cell; nohl; cbeg=-70; cend=32.5; cint=2.5; colr=dark.red;>
 cosq=-70,sn70,-65,sn65,-60,sn60,-55,sn55,-50,sn50,-45,sn45,-40,sn40,-35,sn35,-30,sn30,-25,sn25,-20,sn20,-15,sn15,-10,sn10,-5,sn05,0.,sn00,5,sp05,10,sp10,15,sp15,20,sp20,25,sp25,30,sp30,35,sp35
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=LH; ptyp=hc; cmth=cell; colr=blue; cint=10.; vcor=s; levs=.999; smth=0;>
 cbeg=-200.; cend=2000;>
 cosq=-500.,white,-400.,med.gray,-200.,dark.blue,-100.,magenta,-10.,white,0.,white,10.,light.blue,100.,light.green,200.,light.yellow,300.,light.orange,400.,light.red,500.,dark.red,600.,brown,1000.,med.gray,1500,light.gray,2000.,white
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=HFX; ptyp=hc; cmth=cell; colr=blue; cint=10.; vcor=s; levs=.999; smth=0;>
 cbeg=-200.; cend=2000;>
 cosq=-500.,white,-400.,med.gray,-200.,dark.blue,-100.,magenta,-10.,white,0.,white,10.,light.blue,100.,light.green,200.,light.yellow,300.,light.orange,400.,light.red,500.,dark.red,600.,brown,1000.,med.gray,1500,light.gray,2000.,white
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=tgc; ptyp=hc; cmth=cell; colr=blue; cint=5.; vcor=s; levs=1fb; smth=0;>
 cbeg=-60.; cend=60;>
 cosq=-58.,white,-40.,med.gray,-11.,light.violet,-6.,light.blue,-1.,surf.green,4.,forest.green,11.,parchment,16.,light.orange,21.,med.red,26.,peach,31.,light.gray,36.,dark.red,46.,brown,56.,gold,61.,white
feld=tgc; ptyp=hc; linw=1; cbeg=200; cint=5; colr=black; smth=0; nmsg; nttl; pwhl=0.
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=SMOIS01; ptyp=hc; cmth=cell; colr=blue; cbeg=0.; cend=1.; cint=0.05;>
 vcor=s; levs=1fb; smth=0;>
 cosq=-1.,white,.1,dark.red,.2,peach,.3,light.green,.5,dark.green,.6,dark.blue,.86,white,.9,powder.blue,1.,powder.blue
feld=SMOIS01; ptyp=hc; linw=1; cbeg=200.; cint=10.; colr=black; smth=0;>
  mjsk=1; pwlb=0.; tslb=.010; nttl; nmsg
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
feld=SNOWH; ptyp=hc; cmth=fill; cbeg=0.001; cint=2; mult;>
 diff=0; titl=New_snowfall;>
 cosq=-.5,white,.0009,white,.008,light.purple,.032,light.blue,.0999,blue,.10,yellow,.2499,yellow,.25,orange,.511,orange,.512,red,1.023,red,1.024,violet,2.047,violet,2.048,white
feld=SNOWH; ptyp=hc; linw=1; mult; cbeg=200.; cint=2.; colr=black;>
 diff=0; levs=1; smth=0; mjsk=4; nttl; pwhl=0.
feld=map; ptyp=hb; ouds=solid; oulw=1; cint=10.; mllm=land; outy=Earth..1L4
feld=tic; ptyp=hb; axlg=20; axtg=5
===========================================================================
