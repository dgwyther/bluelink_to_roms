#include <mex.h>

/*
 * idata = roms_mexgridder( data, lon, lat, ilon, ilat, scale, offset)
 * 
 * This function loops through all times of data(lat,lon,time) to grid
 * each time into the given ilon and ilat coordinates. Because the loop
 * is handled in 'C', it is on the order of 10-15x faster than doing
 * it in matlab.
 */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  int i, j, dims[3], subs[3], dat_len, out_len, out_index, dat_index;
  char *options[1];
  double *out, *grid, *data;
  double scale, offset;
  mxArray *rhs[7], *lhs[1];
  
  /* Setup the options */
  options[0] = mxCalloc(20, sizeof(char));
  strcpy(options[0], "cubic");
  
  /* Create a new array */
  scale = mxGetScalar(prhs[5]);
  offset = mxGetScalar(prhs[6]);
  dims[0] = (mxGetDimensions(prhs[3]))[0];
  dims[1] = (mxGetDimensions(prhs[3]))[1];
	if ( mxGetNumberOfDimensions(prhs[0]) < 3 )
		dims[2]=1;
	else
  	dims[2] = (mxGetDimensions(prhs[0]))[2];
  plhs[0] = mxCreateNumericArray( 3, dims, mxDOUBLE_CLASS, mxREAL);
  lhs[0] = mxCreateDoubleMatrix( dims[0],dims[1],mxREAL );
  out_len = dims[0]*dims[1];
  dims[0] = (mxGetDimensions(prhs[0]))[0];
  dims[1] = (mxGetDimensions(prhs[0]))[1];
  dat_len = dims[0]*dims[1]*sizeof(double);

  /*Set up the lat/lon arrays for griddata*/
  rhs[0]=(mxArray*)prhs[1];
  rhs[1]=(mxArray*)prhs[2];
  rhs[2]=mxCreateDoubleMatrix(dims[0],dims[1],mxREAL);
  rhs[3]=(mxArray*)prhs[3];
  rhs[4]=(mxArray*)prhs[4];
  rhs[5]=mxCreateCharMatrixFromStrings(1,(const char **)options);
  rhs[6]=mxCreateCellMatrix(1, 1);
  strcpy(options[0], "QJ");
  mxSetCell(rhs[6],0,mxCreateCharMatrixFromStrings(1,(const char **)options));
  mxFree(options[0]);


  data = mxGetPr(rhs[2]);
  out = mxGetPr(plhs[0]);
  /*Loop over all times calling griddata*/
  subs[0]=0;
  subs[1]=0;
  printf("Interpolation Looping to %d\n",dims[2]);
  if ( scale != 1.0 || offset != 0.0 )
    printf("x=ncep*%lf + %lf\n",scale, offset);
  else
    out_len *= sizeof(double);
  for ( i=0; i<dims[2]; i++ ) {
    subs[2]=i;
    out_index = mxCalcSingleSubscript( plhs[0], 3, subs );
    dat_index = mxCalcSingleSubscript( prhs[0], 3, subs );
    memcpy(data,&(mxGetPr(prhs[0])[dat_index]),dat_len);
    mexCallMATLAB(1,lhs,7,rhs,"griddata");
    grid = mxGetPr(lhs[0]);
    if ( scale != 1.0 || offset != 0.0 )
      for ( j=0; j<out_len; j++ )
        out[out_index+j] = grid[j]*scale + offset;
    else
      memcpy(&(out[out_index]), grid, out_len);
  }
} 
