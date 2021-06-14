	
	;----TS change--------------------------------------------------------------------------------------------;
	ft	= addfile("/glade/work/wliang/CESM/Large_Ensembles_Sets/JJA_Global/trend/TS/Data/TS_ALL.nc","r")
	
	dt	= dim_avg_n_Wrap(dim_avg_n_Wrap(ft->dt,0),0)
	;printVarSummary(dt)
	DT	= dt({20:70},{85:170})
	;----VIQ change------------------------------;
	fqo	= addfile("/glade/work/wliang/CESM/Large_Ensembles_Sets/JJA_Global/trend/Total_QV_Flux/20th/Data/QV_ALL.nc","r")
	fqn	= addfile("/glade/work/wliang/CESM/Large_Ensembles_Sets/JJA_Global/trend/Total_QV_Flux/rcp85/Data/QV_ALL.nc","r")

	VIQo	= fqo->VIq(:,0:29,{20:70},{85:170})
	VIQn	= fqn->VIq(:,0:29,{20:70},{85:170})
	
	qo	= dim_avg_n_Wrap(dim_avg_n_Wrap(VIQo,0),0)
	qn	= dim_avg_n_Wrap(dim_avg_n_Wrap(VIQn,0),0)
	dq	= qo
	dq	= (qn - qo)/qo*100./DT	;({20:70},{80:170})
	;dqm	= avg(dq)
	dqm 	= (avg(qn)-avg(qo))/avg(qo)/avg(DT)*100.
	print(dqm)	
	;----PRE change-------------------------------------------------------------------------------------------;
	f	= addfile("Ttest/TVALUE_PRE.nc","r")

	Tvalue	= f->Tvalue
	Tm	= f->Tm
	Pold	= f->his	;({20:70},{210:310})
	Pnew	= f->rcp	;({20:70},{210:310})
	lat	= Pold&lat
	lon	= Pold&lon

	E_P	= Pold
	E_P	= (Pnew - Pold)/Pold/dt	
	E_P	= E_P*100
	dims	= dimsizes(Tm)

	
	;----maks the land---------------------;
	a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
   	lsdata = a->LSMASK
	lsm  = landsea_mask(lsdata,E_P&lat,E_P&lon)
	Pland	= E_P
	Pocean	= E_P
   	Pland = mask(E_P,lsm.eq.0,False)
   	Pocean= mask(E_P,lsm.eq.1,False)
	print(avg(Pland({20:70},{85:170})))
	print(avg(Pocean({20:70},{85:170})))
	;printVarSummary(Pocean)
	print(avg(Pocean({20:35},{85:170})))
	;---ploting---------------------------------------------------;	
	wks	= gsn_open_wks("png","JJA_PRE_Mean_and_Change")
	gsn_define_colormap(wks,"MPL_BrBG")
	;gsn_define_colormap(wks,"BlWhRe")
	
	res	= True
	res@cnFillOn		= True
	res@cnLinesOn		= False
	res@gsnFrame		= False
	res@gsnDraw		= False
	res@gsnMaximize			= True
	print(dims)
	
	res@mpMinLatF                   = 20      ; range to zoom in     on
        res@mpMaxLatF                   = 70
        res@mpMinLonF                   = 85
        res@mpMaxLonF                   = 170
        res@mpCenterLonF                = 100
        res@gsnAddCyclic                = True
	
	res@cnLevelSelectionMode        = "ManualLevels"     ; set manual contour levels
        res@cnMinLevelValF              = -12              ; set min contour level
        res@cnMaxLevelValF              = 12      ; set max contour level
        res@cnLevelSpacingF             = 1          ; set contour spacing

	resc				 = True
	resc@cnLevelSelectionMode        = "ExplicitLevels"     ; set manual contour levels
        resc@cnLevels     	         = (/2.6,3,4,5,6,7/)              ; set min contour level
        resc@cnLineLabelsOn		 = True
	resc@gsnAddCyclic                = False

	resc@cnLineLabelInterval	 = 1
	resc@cnLineLabelPlacementMode 	 = "constant"
	resc@cnLineThicknessF		 = 6
	resc@cnLineColor		 = "red"
	resc@cnLineLabelFontColor	= "red"
	resc@gsnContourNegLineDashPattern = 2
	resc@cnLineDashSegLenF		= 0.1

	;---polish the pics--------------------------------;
	res@gsnLeftString	= " "
	res@gsnRightString	= " "
	res@tiMainString	= " "
	
	res@pmLabelBarWidthF	= 0.7
	res@pmLabelBarHeightF	= 0.15
	res@lbBoxMinorExtentF 	= 0.2 ;-- decrease height of labelbar boxes and vp
	;res@lbBoxLinesOn 	= False ;-- don't draw lines around labelbar boxes
	res@lbLabelFontColor 	= "black" ;-- label color
	res@lbLabelFontHeightF 	= 0.018 ;-- label font height
	;res@lbLabelOffsetF 	= 0.07
	res@pmLabelBarOrthogonalPosF	= 0.08

	resc@cnInfoLabelOn	= False
	res@tmXBLabelFontHeightF= 0.018
	res@tmYLLabelFontHeightF= 0.018
	
	;resc@cnLineLabelFont	 	= "helvetica-bold"
	resc@cnLineLabelFontHeightF	= 0.018


	Meano	= runave_n_Wrap(runave_n_Wrap(dt,15,1,0),15,1,1)
	plot	= gsn_csm_contour_map_overlay(wks,E_P,Meano,res,resc)
	
	;---plot the 7% line PRE---------------------------------;
	resc1				 = True
	resc1@gsnFrame		= False
	resc1@gsnDraw		= False
	resc1@gsnLeftString	= " "
	resc1@gsnRightString	= " "
	resc1@tiMainString	= " "
	
	resc1@cnLevelSelectionMode        = "ExplicitLevels"     ; set manual contour levels
        resc1@cnLevels     	         = (/7.3/)              ; set min contour level
        resc1@cnLineLabelsOn		 = True
	resc1@gsnAddCyclic                = False

	resc1@cnLineLabelInterval	 = 1
	resc1@cnLineLabelPlacementMode 	 = "constant"
	resc1@cnLineThicknessF		 = 10
	resc1@cnLineColor		 = "black"
	resc1@cnLineLabelFontColor	= "black"
	;resc1@cnLineColor		 = "green"
	;resc1@cnLineLabelFontColor	= "green"
	resc1@gsnContourNegLineDashPattern = 2
	resc1@cnLineDashSegLenF		= 0.1
	
	resc1@cnLineLabelFontHeightF	= 0.018
	resc1@cnInfoLabelOn	= False
	dp	= runave_n_Wrap(runave_n_Wrap(E_P,5,1,0),5,1,1)
	pcon	= gsn_csm_contour(wks,dp,resc1)

	overlay(plot,pcon)
	;---plot the 7% line of VIQ---------------------------------;
	resc2				 = True
	resc2@gsnFrame		= False
	resc2@gsnDraw		= False
	resc2@gsnLeftString	= " "
	resc2@gsnRightString	= " "
	resc2@tiMainString	= " "
	
	resc2@cnLevelSelectionMode        = "ExplicitLevels"     ; set manual contour levels
        resc2@cnLevels     	         = (dqm)              ; set min contour level
        resc2@cnLineLabelsOn		 = True
	resc2@gsnAddCyclic                = False

	resc2@cnLineLabelInterval	 = 1
	resc2@cnLineLabelPlacementMode 	 = "constant"
	resc2@cnLineThicknessF		 = 10
	resc2@cnLineColor		 = "purple"
	;resc2@cnLineColor		 = "green"
	;resc2@cnLineLabelFontColor	= "green"
	resc2@cnLineLabelFontColor	= "purple"
	resc2@cnLineDashPattern 	= 2
	resc2@cnLineDashSegLenF		= 0.1
	
	resc2@cnLineLabelFontHeightF	= 0.016
	resc2@cnInfoLabelOn	= False
	;dq	= runave_n_Wrap(runave_n_Wrap(dq,5,1,0),5,1,1)
	;qcon	= gsn_csm_contour(wks,dp,resc2)

	;overlay(plot,qcon)
	
	;----significant test ploting----------------------------------------;
	draw(plot)
	
	res1				= True
	res1@gsMarkerIndex		= 16
	res1@gsMarkerSizeF		= 0.0015	
	res1@gsMarkerColor		= "gray10"

	siglel	= 0.05
	
	do i=0,dims(0)-1
		do j=0, dims(1)-1
			;if(abs(Tm(i,j)) .gt. siglel .or. avg(abs(Tvalue(:,i,j))) .gt. siglel) then
			if(abs(Tm(i,j)) .le. siglel ) then
				;if(avg(abs(Tvalue(:,i,j))) .le. siglel) then
					if(lat(i) .gt. 20 .and. lon(j) .gt. 85 ) then
						gsn_polymarker(wks,plot,lon(j),lat(i),res1)
						;print("robust")
					end if
				;end if
			end if
		end do
	end do
	frame(wks)

