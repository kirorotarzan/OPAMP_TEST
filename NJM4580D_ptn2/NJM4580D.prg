@@HISTORY

@@END_HISTORY

  void GB_Assign(int GB_idx,double SetValue[MAX_TEST_SITE])
  {
   for(int site_idx=0;site_idx<Sys_TEST_DIE;site_idx++)
    {
     GB[(GB_idx-1)+64*site_idx]=SetValue[site_idx];
    }
  }

/*------------------------------------------------------------------------------------------------------*/
/*                                    Global Variable Setting                                           */
/*------------------------------------------------------------------------------------------------------*/
  void GB_Assign(int GB_idx,double SetValue[MAX_TEST_SITE]);
  char buffer[512];
  int show_mess =1;
  void USER_MESSAGE(char * str);
  int unit_site;



/*------------------------------------------------------------------------------------------------------*/


@@START_UP

  //----- Utility Power Setting -----
  IO_SET_DUT_BOARD_POWER(ON, 5V_USER_POWER, 15V_USER_POWER); //UTL_5V, UTL_15V -> ON


@@END_START_UP


@@SOW
@@END_SOW

@@EOW
@@END_EOW

@@EOT
@@END_EOT


@@BOOKING
  
  OP_AMP_TEST;
  HANTENZOUFUKU_KAIRO_TEST;



@@END_BOOKING


@@UNBOOKING



@@END_UNBOOKING


/*------------------------------------------------------------------------------------------------------*/
/*                                             MACRO                                                    */
/*------------------------------------------------------------------------------------------------------*/

// Unit Change For V/A/Hz ----------------------------------
@@MACRO UNIT_CHANGE_u
  for(unit_site=0; unit_site<Sys_TEST_DIE; unit_site++)
  {
    GB[0+64*unit_site] = Sys_MEASURE_VALUE[unit_site] * 1000000 ;  //Unit Change ( Def -> u )
  }
@@END_MACRO

@@MACRO UNIT_CHANGE_m
  for(unit_site=0; unit_site<Sys_TEST_DIE; unit_site++)
  {
    GB[0+64*unit_site] = Sys_MEASURE_VALUE[unit_site] * 1000 ;  //Unit Change ( Def -> m )
  }
@@END_MACRO

@@MACRO UNIT_CHANGE_n
  for(unit_site=0; unit_site<Sys_TEST_DIE; unit_site++)
  {
    GB[0+64*unit_site] = Sys_MEASURE_VALUE[unit_site] * 1000000000 ;  //Unit Change ( Def -> n )
  }
@@END_MACRO

@@MACRO UNIT_CHANGE_k
  for(unit_site=0; unit_site<Sys_TEST_DIE; unit_site++)
  {
    GB[0+64*unit_site] = Sys_MEASURE_VALUE[unit_site] / 1000 ;  //Unit Change ( Def -> k )
  }
@@END_MACRO

@@MACRO UNIT_CHANGE_M
  for(unit_site=0; unit_site<Sys_TEST_DIE; unit_site++)
  {
    GB[0+64*unit_site] = Sys_MEASURE_VALUE[unit_site] / 1000000 ;  //Unit Change ( Def -> M )
  }
@@END_MACRO

// Unit Change For sec ----------------------------------
@@MACRO UNIT_CHANGE_ns_us
  for(unit_site=0; unit_site<Sys_TEST_DIE; unit_site++)
  {
    GB[0+64*unit_site] = Sys_MEASURE_VALUE[unit_site] / 1000 ;  //Unit No Change ( ns(Def) -> us )
  }
@@END_MACRO

@@MACRO UNIT_CHANGE_ns_ms
  for(unit_site=0; unit_site<Sys_TEST_DIE; unit_site++)
  {
    GB[0+64*unit_site] = Sys_MEASURE_VALUE[unit_site] / 1000000 ;  //Unit No Change ( ns(Def) -> ms )
  }
@@END_MACRO

// Unit Change For Nochange ----------------------------------
@@MACRO UNIT_CHANGE_NOTHING
  for(unit_site=0; unit_site<Sys_TEST_DIE; unit_site++)
  {
    GB[0+64*unit_site] = Sys_MEASURE_VALUE[unit_site] ;  //Unit No Change ( Def -> Def )
  }
@@END_MACRO


@@MACRO TMU_Error_Val_Check
  for(int site=0;site<Sys_TEST_DIE;site++)
  {
    if(Sys_ActiveSite[site]==1 && GB[0+site*64]==0)//Sys_ActiveSite -> 0: Disable, 1: Active
    {
      GB[0+site*64]=1e+20;
    }
  }
@@END_MACRO



/*------------------------------------------------------------------------------------------------------*/
/*                                             Main Program                                             */
/*------------------------------------------------------------------------------------------------------*/


@@PLAN OP_AMP_TEST
  SITE_SEQUENCE       = OFF;
  DISABLE_BY_MARK_NO  = NULL;
  REMARK              = AMP_TEST;
  GO_THROUGH          = OFF;

  MIX_HR_DIG_PATH_SET(HR_DIG,INPUT=SINGLE_END,GAIN=1,FILTER=ALL_PASS,ADC_FILTER=ALL_PASS,OFFSET_V=0V,TRIG_SEL=DDS,CH_RLY_OFF,TRIG_TYPE=HIGH_ACTIVE);  
  MIX_HR_AWG_PATH_SET(HR_AWG,FILTER=ALL_PASS,GAIN=1,OUTPUT=SINGLE_END,OFFSET_V=0V,CH_RLY_OFF);
  WAIT(1ms);

  MIX_HR_DIG_FREQ_SET(HR_DIG,FT=1kHz,N=512,M=3);
  MIX_HR_AWG_FREQ_SET(HR_AWG,FT=1kHz,N=512,M=3);
  WAIT(1ms);

  MIX_HR_AWG_SET_DC_VALUE(HR_AWG,10V);
  WAIT(3ms);


  MIX_HR_AWG_START_SYNTHESIZE(HR_AWG,Freq1kHz_Bin3_4Vpp:START,Freq1kHz_Bin3_4Vpp:END,REPEAT,TRIG_SEL=DDS,TRIG_TYPE=HIGH_ACTIVE); //DDS=Free Run
  WAIT(10ms);

  MIX_HR_DIG_ACQUISITION(HR_DIG,0,511,TIME_OUT=100ms);
  MIX_HR_DIG_SRAM_READ(HR_DIG,512,0,DIG_data);
  MIX_FFT_MAG(DIG_data);



  GB_Assign(1,Sys_SW_BUFFER_DATA_AVG);
  C_COMPARE(GB1,UP_LIMIT=0.01,DOWN_LIMIT=-0.01,LOG_ALIAS=1_OFFSET_Vol,LOG_UNIT=V,BinNo=2);

  GB_Assign(1,Sys_SW_BUFFER_DATA_MIN);
  C_COMPARE(GB1,UP_LIMIT=-1.99,DOWN_LIMIT=-2.01,LOG_ALIAS=1_AMPTD_Min,LOG_UNIT=V,BinNo=2);

  GB_Assign(1,Sys_SW_BUFFER_DATA_MAX);
  C_COMPARE(GB1,UP_LIMIT=2.01,DOWN_LIMIT=1.99,LOG_ALIAS=1_AMPTD_Max,LOG_UNIT=V,BinNo=2);

  GB_Assign(1,Sys_SW_BUFFER_DATA_VPP);
  C_COMPARE(GB1,UP_LIMIT=4.01,DOWN_LIMIT=3.99,LOG_ALIAS=1_AMPTD_Vpp,LOG_UNIT=Vpp,BinNo=2);


  MIX_SNR(3,UP_LIMIT=150dB,DOWN_LIMIT=50dB,FFT_MAG_AMP_CNT=60,LOG_ALIAS=1_SNR,LOG_UNIT=dB,BinNo=2);//FFT_MAG_AMP_CNT = 計算対象の上限BinNo

  MIX_THD(3,UP_LIMIT=-50dB,DOWN_LIMIT=-150dB,FFT_MAG_AMP_CNT=60,LOG_ALIAS=1_THD,LOG_UNIT=dB,BinNo=2);

  MIX_SINAD(3, UP_LIMIT=150dB, DOWN_LIMIT=50dB,FFT_MAG_AMP_CNT=60,LOG_ALIAS=1_SINAD,LOG_UNIT=dB,BinNo=2);


  GO_THROUGH_BLOCK();
  {
  MIX_HR_AWG_STOP_SYNTHESIZE(HR_AWG,RLY_ON);
  WAIT(3ms);
  MIX_HR_AWG_PATH_SET(HR_AWG,CH_RLY_OFF);
  MIX_HR_DIG_PATH_SET(HR_DIG,CH_RLY_OFF);
  WAIT(3ms);
  }


  CONDITION
  IF_FAIL
  REJECT_BIN=2;
@@END_PLAN
 


@@PLAN HANTENZOUFUKU_KAIRO_TEST;
  SITE_SEQUENCE       = OFF;
  DISABLE_BY_MARK_NO  = NULL;
  REMARK              = AMP_TEST;
  GO_THROUGH          = OFF;

  MIX_HR_DIG_PATH_SET(HR_DIG,INPUT=SINGLE_END,GAIN=1,FILTER=ALL_PASS,ADC_FILTER=ALL_PASS,OFFSET_V=0V,TRIG_SEL=DDS,CH_RLY_OFF,TRIG_TYPE=HIGH_ACTIVE);  
  MIX_HR_AWG_PATH_SET(HR_AWG,FILTER=ALL_PASS,GAIN=1,OUTPUT=SINGLE_END,OFFSET_V=0V,CH_RLY_OFF);
  WAIT(1ms);

  MIX_HR_DIG_FREQ_SET(HR_DIG,FT=1kHz,N=512,M=3);
  MIX_HR_AWG_FREQ_SET(HR_AWG,FT=1kHz,N=512,M=3);
  WAIT(1ms);

  MIX_HR_AWG_SET_DC_VALUE(HR_AWG,10V);
  WAIT(3ms);

  MIX_HR_AWG_START_SYNTHESIZE(HR_AWG,Freq1kHz_Bin3_4Vpp:START,Freq1kHz_Bin3_4Vpp:END,REPEAT,TRIG_SEL=DDS,TRIG_TYPE=HIGH_ACTIVE); //DDS=Free Run
  WAIT(10ms);

  MIX_HR_DIG_ACQUISITION(HR_DIG,0,511,TIME_OUT=100ms);
  MIX_HR_DIG_SRAM_READ(HR_DIG,512,0,DIG_data);
  MIX_FFT_MAG(DIG_data);



  GB_Assign(1,Sys_SW_BUFFER_DATA_AVG);
  C_COMPARE(GB1,UP_LIMIT=0.01,DOWN_LIMIT=-0.01,LOG_ALIAS=1_OFFSET_Vol,LOG_UNIT=V,BinNo=2);

  GB_Assign(1,Sys_SW_BUFFER_DATA_MIN);
  C_COMPARE(GB1,UP_LIMIT=-1.99,DOWN_LIMIT=-2.01,LOG_ALIAS=1_AMPTD_Min,LOG_UNIT=V,BinNo=2);

  GB_Assign(1,Sys_SW_BUFFER_DATA_MAX);
  C_COMPARE(GB1,UP_LIMIT=2.01,DOWN_LIMIT=1.99,LOG_ALIAS=1_AMPTD_Max,LOG_UNIT=V,BinNo=2);

  GB_Assign(1,Sys_SW_BUFFER_DATA_VPP);
  C_COMPARE(GB1,UP_LIMIT=4.01,DOWN_LIMIT=3.99,LOG_ALIAS=1_AMPTD_Vpp,LOG_UNIT=Vpp,BinNo=2);


  MIX_SNR(3,UP_LIMIT=150dB,DOWN_LIMIT=50dB,FFT_MAG_AMP_CNT=60,LOG_ALIAS=1_SNR,LOG_UNIT=dB,BinNo=2);//FFT_MAG_AMP_CNT = 計算対象の上限BinNo

  MIX_THD(3,UP_LIMIT=-50dB,DOWN_LIMIT=-150dB,FFT_MAG_AMP_CNT=60,LOG_ALIAS=1_THD,LOG_UNIT=dB,BinNo=2);

  MIX_SINAD(3, UP_LIMIT=150dB, DOWN_LIMIT=50dB,FFT_MAG_AMP_CNT=60,LOG_ALIAS=1_SINAD,LOG_UNIT=dB,BinNo=2);


  GO_THROUGH_BLOCK();
  {
  MIX_HR_AWG_STOP_SYNTHESIZE(HR_AWG,RLY_ON);
  WAIT(3ms);
  MIX_HR_AWG_PATH_SET(HR_AWG,CH_RLY_OFF);
  MIX_HR_DIG_PATH_SET(HR_DIG,CH_RLY_OFF);
  WAIT(3ms);
  }


  CONDITION
  IF_FAIL
  REJECT_BIN=2;
@@END_PLAN




