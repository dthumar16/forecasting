/*Import and SORT ddataset by niin and hist_period*/
/*Change the program name - fcst_calc*/

PROC SORT data=test;
	by niin hist_period;
RUN;

/*transpose the dataset by niin */
/*need to put addtional variables for retain*/
PROC TRANSPOSE data=test out=dt1_fcst (rename=(_name_=dmd_qtr col1 = dmd_qty));
	by niin hist_period;
RUN;

/*SORT dataset by descending qtr*/
/*this will be easier to do backcasting by using first.niin*/
PROC SORT data= dt1_fcst;
	by niin descending dmd_qtr;
RUN;

/*Calculate backcasting by using first.niin*/
data backcast (drop=previous current);
	set dt1_fcst;
	by niin descending dmd_qtr;
	retain previous obs;
	if first.niin then do; 
		previous = .;
		obs = .;
		obs = 1;
		final = dmd_qty;
	end;
	else do;
	obs + 1;
		retain final;
		previous = final*0.8;
		current = dmd_qty *0.2;
		final = previous + current;
	end;
RUN;

/*Subset dataset by using hist_period period*/
data backcast (drop=obs);
set backcast;
if obs <= hist_period then output;
run;


/*SORT dataset by ascending qtr*/
/*this will be easier to do forecasting by using first.niin*/
PROC SORT data=backcast;
	by niin dmd_qtr;
RUN;

/*Calculate forecasting by using first.niin*/
data forecast (keep=niin hist_period forecast);
	set backcast;
	by niin dmd_qtr;
	retain previous;
	if first.niin then do;
		previous = .;
		final1 = final;
	end;
	else do;
		retain final1;
		previous = final1*0.8;
		current = final *0.2;
		final1 = previous + current;
	end;

/*	Change the column name*/
	rename final = backcast final1 = forecast;
	if last.niin then output;
RUN;

PROC SORT data=forecast;
	by niin;
RUN;


