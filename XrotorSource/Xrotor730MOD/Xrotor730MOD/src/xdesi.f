
      SUBROUTINE DESI
      INCLUDE 'XROTOR.INC'
      CHARACTER*4 COMAND, CONSTR, ANS
      CHARACTER*132 COMARG, PARARG
      CHARACTER*12 CHPARM(11)
C
      DIMENSION IINPUT(20)
      DIMENSION RINPUT(20)
      LOGICAL ERROR, CHANGE
C
C----------------------------------------------------------
C     Input or edit design parameters and design MIL rotor
C----------------------------------------------------------
      PLFACD = 0.6
      PLFAC1 = 0.7
      PLFAC2 = 0.85
      XORG = 0.15
      YORG = 0.10
C
      GREEK = .FALSE.
C
 900  CONTINUE
C
C---- assume some design parameter has been modified
      CHANGE = .TRUE.
C
      CALL ASKC('.DESI^',COMAND,COMARG)
C
      DO I=1, 20
        IINPUT(I) = 0
        RINPUT(I) = 0.0
      ENDDO
      NINPUT = 0
      CALL GETINT(COMARG,IINPUT,NINPUT,ERROR)
      NINPUT = 0
      CALL GETFLT(COMARG,RINPUT,NINPUT,ERROR)
C
      IF(COMAND.EQ.'    ') THEN
       WRITE(*,*) 'Funzione disabilitata'
       RETURN
      ENDIF
      IF(COMAND.EQ.'?   ') WRITE(*,1100)
      IF(COMAND.EQ.'?   ') GO TO 900
      IF(COMAND.EQ.'VRTX') GO TO 5
      IF(COMAND.EQ.'FORM') GO TO 10
      IF(COMAND.EQ.'WAKE') GO TO 12
      IF(COMAND.EQ.'INPU') GO TO 20
      IF(COMAND.EQ.'EDIT') GO TO 30
      IF(COMAND.EQ.'ATMO') GO TO 35
      IF(COMAND.EQ.'N   ') GO TO 50
      IF(COMAND.EQ.'DISP') GO TO 60
      IF(COMAND.EQ.'TERS') GO TO 14
      IF(COMAND.EQ.'NAME') GO TO 65
      IF(COMAND.EQ.'PLOT') GO TO 90
      IF(COMAND.EQ.'ANNO') GO TO 92
      IF(COMAND.EQ.'HARD') GO TO 94
      IF(COMAND.EQ.'SIZE') GO TO 96
      IF(COMAND.EQ.'ITER') GO TO 40
C
      IF(COMAND.EQ.'Z   ') THEN
       WRITE(*,*) 'Funzione disabilitata'
       GO TO 900
      ENDIF
      IF(COMAND.EQ.'U   ') THEN
       WRITE(*,*) 'Funzione disabilitata'
       GO TO 900
      ENDIF
      WRITE(*,1000) COMAND
      GO TO 900
C
C---------------------------------------------------------------------
 5    VRTX = .NOT.VRTX
      IF(.NOT.VRTX) WRITE(*,*)'Discrete Vortex Formulation deselected'
      IF(VRTX)      WRITE(*,*)'Discrete Vortex Formulation selected'
      GO TO 900
C
C---------------------------------------------------------------------
 10   FAST = .NOT.FAST
      IF(FAST)      WRITE(*,*)'Graded Momentum Formulation selected'
      IF(.NOT.FAST) WRITE(*,*)'Potential Formulation selected'
      GO TO 900
C
C---------------------------------------------------------------------
 12   FREE = .NOT.FREE
      IF(FREE)      WRITE(*,*)'Self-deforming wake selected'
      IF(.NOT.FREE) WRITE(*,*)'Rigid wake selected'
      GO TO 900
C
C---------------------------------------------------------------------
 14   TERSE = .NOT.TERSE
      IF(TERSE)      WRITE(*,*)'Terse output selected'
      IF(.NOT.TERSE) WRITE(*,*)'Verbose output selected'
      GO TO 900
C
C---------------------------------------------------------------------
 20   CALL ASKI('number of blades ^',NBLDS)
      CALL ASKR('tip radius (m)   ^',RADDES)
      CALL ASKR('hub radius (m)   ^',R0DES)
      CALL ASKR('hub wake displacement body radius (m) ^',RWDES)
      CALL ASKR('airspeed(m/s)    ^',VELDES)
      ADVDES = 0.
      RPMDES = 0.
      CALL ASKR('advance ratio (0 to prescribe rpm)^',ADVDES)
      IF(ADVDES.EQ.0.0)
     &CALL ASKR('rpm              ^',RPMDES)
      TDDES = 0.
      PDDES = 0.
 21   CALL ASKR('thrust(N)  (0 to prescribe power )^',TDDES)
      IF(TDDES.EQ.0.0)
     &CALL ASKR('power (W)        ^',PDDES)
      IF(TDDES.EQ.0.0 .AND. PDDES.EQ.0.0) GO TO 21
      DEST = TDDES .NE. 0.0
      DESP = .NOT.DEST
      CALL ASKR('lift coefficient ^',CLDES0)
      IF(CLDES0 .EQ. 0.0) THEN
        IF(DEST) CLDES1 = SIGN(0.8,TDDES)
        IF(DESP) CLDES1 = SIGN(0.8,PDDES)
        CALL SETCLD(CLDES1,CLDES1)
      ELSE
        CALL SETCLD(CLDES0,CLDES0)
      ENDIF
C
      IF(DEST .AND. TDDES*CLDES0 .LT. 0.0) THEN
          WRITE(*,*)
     &      'WARNING: Design thrust and CL should have the same sign.'
      ENDIF
C
      IF(DESP .AND. PDDES*CLDES0 .LT. 0.0) THEN
          WRITE(*,*)
     &      'WARNING: Design power and CL should have the same sign.'
      ENDIF
C
      IF(NAME.EQ.' ') NAME = 'Designed blade'
      LROTOR = .FALSE.
C
C---------------------------------------------------------------------
 30   CONTINUE
      WRITE(CHPARM( 1),'(I4   )') NBLDS
      WRITE(CHPARM( 2),'(F12.4)') RADDES
      WRITE(CHPARM( 3),'(F12.4)') R0DES
      WRITE(CHPARM( 4),'(F12.4)') RWDES
      WRITE(CHPARM( 5),'(F12.4)') VELDES
      WRITE(CHPARM( 6),'(F12.4)') ADVDES
      WRITE(CHPARM( 7),'(F12.4)') RPMDES
      WRITE(CHPARM( 8),'(F12.4)') TDDES
      WRITE(CHPARM( 9),'(F12.4)') PDDES
      WRITE(CHPARM(10),'(F12.4)') CLDES0
      IF(ADVDES.EQ.0.0) WRITE(CHPARM( 6),'(A)') '      ---   '
      IF(RPMDES.EQ.0.0) WRITE(CHPARM( 7),'(A)') '      ---   '
      IF(TDDES .EQ.0.0) WRITE(CHPARM( 8),'(A)') '      ---   '
      IF(PDDES .EQ.0.0) WRITE(CHPARM( 9),'(A)') '      ---   '
      IF(CLDES0.EQ.0.0) WRITE(CHPARM( 8),'(A)') '      ---   '
C
      WRITE(*,1200) (CHPARM(K), K=1, 10)
C
 305  CALL ASKC('..EDIT   Parameter, Value   (or <Return>)^',ANS,PARARG)
      DO I=1, 20
        IINPUT(I) = 0
        RINPUT(I) = 0.0
      ENDDO
      NINPUT = 0
      CALL GETINT(PARARG,IINPUT,NINPUT,ERROR)
      NINPUT = 0
      CALL GETFLT(PARARG,RINPUT,NINPUT,ERROR)
C
      IF(ANS.EQ.'    ') THEN
       IF(.NOT.CHANGE) GO TO 900
C
       CALL DESGEN
       WRITE(*,*) 'Funzione disabilitata'
       CHANGE = .FALSE.
       GO TO 30
      ENDIF
C
      IF(ANS.EQ.'?   ') GO TO 30
C
      IF    (ANS.EQ.'I   ') THEN
        LDESINI = .NOT. LDESINI
        IF(LDESINI) THEN
          WRITE(*,*) 'Rotor will be initialized for iteration'
        ELSE
          WRITE(*,*) 'Rotor will not be initialized for iteration'
        ENDIF
C
      ELSEIF(ANS.EQ.'B   ') THEN
        IF(NINPUT.GE.1) THEN
         NBLDS = IINPUT(1)
        ELSE
         CALL ASKI('number of blades     ^',NBLDS)
        ENDIF
C
      ELSEIF(ANS.EQ.'RT  ' .OR. ANS.EQ.'RTIP') THEN
        IF(NINPUT.GE.1) THEN
         RADDES = RINPUT(1)
        ELSE
         CALL ASKR('tip radius (m)       ^',RADDES)
        ENDIF
C
      ELSEIF(ANS.EQ.'RH  ' .OR. ANS.EQ.'RHUB') THEN
        IF(NINPUT.GE.1) THEN
         R0DES = RINPUT(1)
        ELSE
         CALL ASKR('hub radius (m)       ^',R0DES)
        ENDIF
C
      ELSEIF(ANS.EQ.'RW  ' .OR. ANS.EQ.'RWAK') THEN
        IF(NINPUT.GE.1) THEN
         RWDES = RINPUT(1)
        ELSE
         CALL ASKR('hub wake displacement body radius (m)^',RWDES)
        ENDIF
C
      ELSEIF(ANS.EQ.'V   ' .OR. ANS.EQ.'VEL ') THEN
        IF(NINPUT.GE.1) THEN
         VELDES = RINPUT(1)
        ELSE
         CALL ASKR('airspeed(m/s) ^',VELDES)
        ENDIF
C
      ELSEIF(ANS.EQ.'A   ' .OR. ANS.EQ.'ADV ') THEN
        IF(NINPUT.GE.1) THEN
         ADVDES = RINPUT(1)
        ELSE
         CALL ASKR('advance ratio ^',ADVDES)
        ENDIF
        RPMDES = 0.
C
      ELSEIF(ANS.EQ.'R   ' .OR. ANS.EQ.'RPM ') THEN
        IF(NINPUT.GE.1) THEN
         RPMDES = RINPUT(1)
        ELSE
         CALL ASKR('rpm           ^',RPMDES)
        ENDIF
        ADVDES = 0.
C
      ELSEIF(ANS.EQ.'T   ') THEN
        IF(NINPUT.GE.1) THEN
         TDDES = RINPUT(1)
        ELSE
         CALL ASKR('thrust (N)^',TDDES)
        ENDIF
        DEST = .TRUE.
        DESP = .FALSE.
        PDDES = 0.
C
      ELSEIF(ANS.EQ.'P   ') THEN
        IF(NINPUT.GE.1) THEN
         PDDES = RINPUT(1)
        ELSE
         CALL ASKR('power (W)^',PDDES)
        ENDIF
        DEST = .FALSE.
        DESP = .TRUE.
        TDDES = 0.
C
      ELSEIF(ANS.EQ.'CC  ') THEN
        IF(NINPUT.GE.1) THEN
         CLDES0 = RINPUT(1)
        ELSE
         CALL ASKR('constant lift coefficient^',CLDES0)
        ENDIF
        CALL SETCLD(CLDES0,CLDES0)
C
      ELSEIF(ANS.EQ.'CL  ') THEN
        CLROOT = 999.0
        CLTIP  = 999.0
        IF(NINPUT.GE.1) THEN
         CLROOT = RINPUT(1)
        ELSE
         CALL ASKR('root lift coefficient^',CLROOT)
        ENDIF
        IF(NINPUT.GT.1) THEN
         CLTIP = RINPUT(2)
        ELSE
         CALL ASKR('tip lift coefficient^',CLTIP)
        ENDIF
        CALL SETCLD(CLROOT,CLTIP)
        CLDES0 = 0.5*(CLROOT+CLTIP)
C
      ELSEIF(ANS.EQ.'CR  ') THEN
        CALL SETCLD(999.,999.)
C
      ELSEIF(ANS.EQ.'CW  ') THEN
        CALL SAVCLD
C
      ELSEIF(ANS.EQ.'CX  ') THEN
        XI0   = R0DES/RADDES
        XITIP = 1.0
        CALL SETX
        WRITE(*,*) 'Funzione disabilitata'
C
      ELSE
        WRITE(*,*) ' '
        WRITE(*,*) '*** Parameter keyword not recognized ***'
        GO TO 30
C
      ENDIF
      CHANGE = .TRUE.
      GO TO 305
C
C---------------------------------------------------------------------
 35   IF(NINPUT.GE.1) THEN
       ALT = RINPUT(1)
      ELSE
       CALL ASKR('flight altitude (km)^',ALT)
      ENDIF
      CALL ATMO(ALT,VSO,RHO,RMU)
      CALL FLOSHO(LUWRIT, VSO, RHO, RMU)
      GO TO 900
C
C---------------------------------------------------------------------
 40   IF(NINPUT.GE.1) THEN
       NITERA = IINPUT(1)
      ELSE
       CALL ASKI('Max number of iterations^',NITERD)
      ENDIF
      GO TO 900
C
C---------------------------------------------------------------------
 50   CONTINUE
      IF(LROTOR) THEN
       IISAV = II
       DO I = 1, IISAV
         W1(I) = XI(I)
         W2(I) = CH(I)
         W4(I) = BETA(I)
         W6(I) = UBODY(I)
         W8(I) = CLDES(I)
       ENDDO
       CALL SPLINE(W2,W3,W1,II)
       CALL SPLINE(W4,W5,W1,II)
       CALL SPLINE(W6,W7,W1,II)
       CALL SPLINE(W8,W9,W1,II)
      ENDIF
C
 51   CALL ASKI('Enter new number of radial points^',II)
      IF(II.GT.IX) THEN
       WRITE(*,*)
       WRITE(*,*) 'Maximum number is', IX
       GO TO 51
      ENDIF
C
      IINF = II + II/2
      CALL SETX
C
      IF(LROTOR) THEN
       DO I = 1, II
         CH(I)    = SEVAL(XI(I),W2,W3,W1,IISAV)
         BETA(I)  = SEVAL(XI(I),W4,W5,W1,IISAV)
         UBODY(I) = SEVAL(XI(I),W6,W7,W1,IISAV)
         CLDES(I) = SEVAL(XI(I),W8,W9,W1,IISAV)
         BETA0(I) = BETA(I)
       ENDDO
      ENDIF
C
      GO TO 900
C
C---------------------------------------------------------------------
 60   CALL OUTPUT(LUWRIT)
      GO TO 900
C
C---------------------------------------------------------------------
 65   NAME = COMARG
      IF(NAME(1:1) .EQ. ' ') 
     & CALL ASKS('Enter case name (32 charaters max)^',NAME)
      GO TO 900
C
C---------------------------------------------------------------------
 90   WRITE(*,*) 'Funzione disabilitata'
      GO TO 900
C
C---------------------------------------------------------------------
 92   WRITE(*,*) 'Funzione disabilitata'
      GO TO 900
C
C---------------------------------------------------------------------
 94   WRITE(*,*) 'Funzione disabilitata'
      GO TO 900
C
C---------------------------------------------------------------------
 96   WRITE(*,*) 'Funzione disabilitata'
      GO TO 900
C
C.....................................................................
C
C
C.....................................................................
C
 1000 FORMAT(1X,A4,' command not recognized.' //
     &             '  Type "?" for list, <Return> to exit menu.')
 1100 FORMAT(
     &  /'   INPU    Input  design parameters... design rotor'
     &  /'  .EDIT    Change design parameters... design rotor'
     &  /'   N       Change number of radial points'
     & //'   VRTX    Toggle between Graded Mom. and Vortex Form.'
     &  /'   FORM    Toggle between Graded Mom. and Potential Form.'
     &  /'   WAKE    Toggle between rigid and self-deforming wake'
     &  /'   ATMO r  Set fluid properties from standard atmosphere'
     & //'   DISP    Display current design point'
     &  /'   TERS    Toggle between terse and verbose output'
     &  /'   NAME s  Set or change case name'
     & //'   PLOT i  Plot various rotor parameters'
     &  /'   ANNO    Annotate current plot'
     &  /'   HARD    Hardcopy current plot'
     &  /'   SIZE r  Change plot-object size')
C 
 1200 FORMAT(
     &  /'         B ',A12,'   number of blades'
     &  /'         RT',A12,'   tip radius'
     &  /'         RH',A12,'   hub radius'
     &  /'         RW',A12,'   hub wake displacement body radius'
     &  /'         V ',A12,'   airspeed'
     &  /'         A ',A12,'   advance ratio'
     &  /'         R ',A12,'   rpm'
     &  /'         T ',A12,'   thrust'
     &  /'         P ',A12,'   power'
     &  /'         CC',A12,'   lift coefficient (constant )'
     &  /'         CL',12X,'   linear lift coefficient (root,tip)' 
     &  /'         CX',12X,'   lift coefficient (cursor input)' 
     &  /'         CR',12X,'   read  CL(r/R) from file'
     &  /'         CW',12X,'   write CL(r/R) to   file' )
 2000 FORMAT(/'  0   CANCEL'
     &       /'  1   Geometry'
     &       /'  2   CL, Circulation, and Local Efficiency  vs  Radius'
     &       /'  3   Both: 1,2 '
     &       /'  5   Induced velocities  vs  Radius'
     &       /'  6   Velocity triangles' )
      END ! DESI


      SUBROUTINE DESGEN
      INCLUDE 'XROTOR.INC'
C-----------------------------------------------------------------
C     Generates MIL rotor design
C-----------------------------------------------------------------
      LOGICAL OK
C
      DO I=1, II
        N = 1
        CALL GETAERO(N,XISECT,A0,CLMAX,CLMIN,
     &              DCLDA,DCLDA_STALL,DCL_STALL,
     &              CDMIN,CLDMIN,DCDCL2,CMCON,MCRIT,REREF,REXP)
        IF(CLDES(I).GT.CLMAX .OR. CLDES(I).LT.CLMIN) THEN
         WRITE(*,*) ' '
         WRITE(*,*) 'Design CL is past stall limit at r/R =', XI(I)
         WRITE(*,*) 'CLmin = ',CLMIN, 'CLmax = ',CLMAX
         WRITE(*,*) 'Try again'
         RETURN
        ENDIF
      ENDDO
C
C---- Set up operating parameters
      CONV = .FALSE.
      BLDS = FLOAT(NBLDS)
      RAD = RADDES
      VEL = VELDES
      IF(ADVDES.EQ.0.0) THEN
       ADV = VELDES/(RADDES*RPMDES*PI/30.0)
      ELSE
       ADV = ADVDES
      ENDIF
C
C---- Check for reasonable thrust or power inputs
      TMIN = -0.5*PI*RHO*VEL**2*RAD**2
      PMIN = -0.5*PI*RHO*VEL**3*RAD**2 * 16.0/27.0
      IF((DEST .AND. TDDES.LT.TMIN).OR.(DESP .AND. PDDES.LT.PMIN)) THEN
       WRITE(*,*) ' '
       WRITE(*,*) '*** Disk loading above ultimate Betz limits ***'
       WRITE(*,*) ' Limiting windmill thrust = ',TMIN,' (N)'
       WRITE(*,*) ' Limiting windmill power  = ',PMIN,' (W)'
       WRITE(*,*) ' '
       CALL ASKL('Continue with design anyway ?^',OK)
       IF(.NOT.OK) RETURN
      ENDIF
C
C---- Non-dimensionalize design thrust or power
      TDES = TDDES/(RHO*VEL**2*RAD**2)
      PDES = PDDES/(RHO*VEL**3*RAD**2)
C
C---- Set up discrete coordinates
      XI0 = R0DES/RAD
      XW0 = RWDES/RAD
      CALL SETX
      CALL XWINIT
C
C---- Fill CL array with design-CL array
      DO I=1, II
        CL(I) = CLDES(I)
        STALL(I) = .FALSE.
      ENDDO
C
C---- Initialize wake advance ratios
      EFFINV = 1.0
      IF(FREE.AND.DEST) EFFINV = 0.50*SQRT(ABS(1.0+TDES*2./PI)) + 0.50
      IF(FREE.AND.DESP) EFFINV = 0.25*SQRT(ABS(1.0+PDES*4./PI)) + 0.75
      UDUCT     = 0.0
      IF(DUCT) THEN
        UDUCT = URDUCT-1.0
      ENDIF
      ADW = EFFINV*ADV*(1.0+UDUCT)
C
C---- Initialize rotor for iteration
      IF(LDESINI .OR. .NOT.LROTOR) CALL DESINI
C
C---- Calculate MIL rotor (varying chord, varying twist, fixed CL case)
      CALL DESMIL(2)
      IF (stampa_schermo) then
      IF(CONV) CALL OUTPUT(LUWRIT)
      WRITE(*,*) 'New rotor geometry created'
      endif
C
      RETURN
      END ! DESGEN



      SUBROUTINE DESINI
      INCLUDE 'XROTOR.INC'
C
C---- Initialize chord array to elliptical-like planform for CD calculation
      DO I=1, II
        XX = XI(I)/ADV
        CH(I) = 0.1*XX*XX*SQRT(XITIP**2 - XI(I)**2)/(1.0 + XX*XX)
      END DO
C
C---- Initialize CD array
      DO I=1, II
        W = SQRT(1.0 + (XI(I)/ADV)**2)
        RE(I) = CH(I)*W *RHO*VEL*RAD/RMU
        CALL GETALF(I,CL(I),W,ALFA,AL_CL,AL_W,STALL(I))
        CALL GETCLCDCM(I,ALFA,W,RE(I),
     &                 CL(I),CL_AL,CL_W,
     &                 CLMAX,CLMIN,DCLSTALL,STALL(I),
     &                 CD(I),CD_AL,CD_W,CD_RE,
     &                 CMOM,CM_AL,CM_W)
      END DO
C
C---- Initialize rotor with Larrabee design method
      BLDS = FLOAT(NBLDS)
      RI1 = 0.
      RI2 = 0.
      RJ1 = 0.
      RJ2 = 0.
      SFAC = SQRT(1.0 + 1.0/ADW**2)
      DO I=1, II
        DX = DXW(I)
        YY = XW(I)/ADV
        YYINV = 1.0 / (1.0 + YY*YY)
        DOL = CD(I)/CL(I)
        ARG = MIN(20.0, 0.5*BLDS*(1.0 - XW(I)/XWTIP)*SFAC)
        EK = EXP(-ARG)
        FK = SQRT(1.0 - EK*EK)
        F = ATAN2(FK,EK)*2.0/PI
        GAM(I) = F*YY*YY*YYINV
        RI1 = RI1 + 4.0*XW(I)*GAM(I)*(1.0 - DOL/YY)*DX
        RI2 = RI2 + 2.0*XW(I)*GAM(I)*(1.0 - DOL/YY)*DX*YYINV
        RJ1 = RJ1 + 4.0*XW(I)*GAM(I)*(1.0 + DOL*YY)*DX
        RJ2 = RJ2 + 2.0*XW(I)*GAM(I)*(1.0 + DOL*YY)*DX*YY*YY*YYINV
      END DO
C
C---- Calculate displacement velocity
      IF(DEST) THEN
       DISC = MAX( 0.0 , 1.0 - 8.0/PI*TDES*RI2/RI1**2 )
       ZETA = 0.5*RI1/RI2 * (1.0 - SQRT(DISC))
      ENDIF
      IF(DESP) THEN
       DISC = MAX( 0.0 , 1.0 + 8.0/PI*PDES*RJ2/RJ1**2 )
       ZETA = 0.5*RJ1/RJ2 * (SQRT(DISC) - 1.0)
      ENDIF
C
      DO I = 1, II
        GAM(I) = GAM(I) * (2.0*PI*ADV/BLDS) * ZETA
      ENDDO
C
C
C---- Better guess for wake advance ratio
      EFFINV = 1.0 + 0.5*ZETA
      UDUCT     = 0.0
      IF(DUCT) THEN
        UDUCT = URDUCT-1.0
      ENDIF
      IF(FREE) ADW = ADV*EFFINV*(1.0+UDUCT)
C
C
      IF(.NOT.FAST) THEN
C------ better guess for Potential Formulation
        IF(.NOT.VRTX) THEN
          CALL HELICO(IX,II, NBLDS, DUCT, RAKE,
     &                XI,XV,GAM, ADW,VIND_GAM,VIND_ADW) 
        ELSEIF(VRTX) THEN
          CALL VRTXCO(IX,II, NBLDS, DUCT, RAKE,
     &                XI,XV,GAM, ADW,VIND_GAM,VIND_ADW) 
        ENDIF
C
C------ set up linear system for Goldstein circulation distribution
C-      by requiring a radially-constant displacement velocity  v'
        DO I=1, II
          YY = XW(I)/ADV
          GAM(I) = 0.5*ZETA * YY / (1.0 + YY*YY)
          DO J=1, II
            Q(I,J) = VIND_GAM(3,I,J)
          ENDDO
        ENDDO
C
C------ solve linear system for G
        CALL GAUSS(IQ,II,Q,GAM,1)
C
      ENDIF
C
C
C---- Calculate circulation and chord
      DO I=1, II
        W = SQRT(1.0 + (XI(I)/ADV)**2)
        CH(I) = 2.0*GAM(I)/(W*CL(I))
      END DO
C
      LROTOR = .TRUE.
C
      RETURN
      END ! DESINI



      SUBROUTINE DESMIL(ICASE)
      INCLUDE 'XROTOR.INC'
C-----------------------------------------------------------------
C     Converges rotor design by applying minimum
C     induced loss condition at each station
C
C     If ICASE=2,  fix present CL distribution   , vary twist & chord
C     If ICASE=3,  fix present chord distribution, vary twist & CL
C-----------------------------------------------------------------
C
      IF(FAST) THEN
C------ Graded Momentum design
C
        CALL DEITER(ICASE)
C
        IF(.NOT.CONV) THEN
         WRITE(*,*) ' '
         WRITE(*,*) 'Graded Mom. iteration limit exceeded'
         IF (stampa_schermo) 
     &    WRITE(*,*) 'Gres Fres Ares =', GRESMX, FRESMX, ARESMX
        ENDIF
C
      ELSEIF(.NOT.VRTX) THEN
C------ Potential Formulation design
C
        CALL DEITER(ICASE)
C
        IF(.NOT.CONV) THEN
         WRITE(*,*) ' '
         WRITE(*,*) 'Pot. iteration limit exceeded'
         IF (stampa_schermo) 
     &    WRITE(*,*) 'Gres Fres Ares =', GRESMX, FRESMX, ARESMX
        ENDIF
C
      ELSEIF(VRTX) THEN
C------ Vortex Wake Formulation design
C
        CALL DEITER(ICASE)
C
        IF(.NOT.CONV) THEN
         WRITE(*,*) ' '
         WRITE(*,*) 'Vortex. iteration limit exceeded'
         IF (stampa_schermo) 
     &    WRITE(*,*) 'Gres Fres Ares =', GRESMX, FRESMX, ARESMX
        ENDIF
C
      ENDIF
C
      RETURN
      END ! DESMIL


      SUBROUTINE DEITER(ICASE)
      INCLUDE 'XROTOR.INC'
C
C---- Converges MIL design operating point
C
      K1 = II+1
      K2 = II+2
C
      DO 1000 ITER=1, MAX( NITERD , 1 )
C
  700 CONTINUE
C
C---- if wake advance ratio changed, recalculate Vtan influence coefficients
      IF(FREE .OR. ITER.EQ.1) THEN
        IF(FAST) THEN
          CALL GRADMO(IX,II, NBLDS, DUCT, RAKE,
     &                XI,XV,GAM, ADW,VIND_GAM,VIND_ADW) 
          IWTYP = 1
        ELSEIF(.NOT.VRTX) THEN
          CALL HELICO(IX,II, NBLDS, DUCT, RAKE,
     &                XI,XV,GAM, ADW,VIND_GAM,VIND_ADW) 
          IWTYP = 2
        ELSEIF(VRTX) THEN
          CALL VRTXCO(IX,II, NBLDS, DUCT, RAKE,
     &                XI,XV,GAM, ADW,VIND_GAM,VIND_ADW) 
          IWTYP = 3
        ENDIF
      ENDIF
C
C
C---- recalculate V-induced
      CALL VCALC
C
C---- recalculate wake radius array and Vwak
      CALL SETXW
      CALL XWINIT
C
C---- recalculate thrust, power, and sensitivities
      CALL TPQ(ICASE)
C
C---- initialize max residuals
      GRESMX = 0.
      FRESMX = 0.
      ARESMX = 0.
C
C---- go over radial stations, setting constant eff. in equivalent prop
      DO 100 I=1, II
C
        VW = VWAK(I)
        VAW = VW*XW(I)/ADW
        VAW_VW  =     XW(I)/ADW 
        VAW_XW  =  VW      /ADW 
        VAW_ADW = -VAW     /ADW
C
        UTOTW = 1.0
        CALL UVADD(XI(I),WA,WT)
C
C---- HHY new assumption is equiv. prop omega_equiv=omega*XI/XW 
        CW     =  XI(I)/ADV - WT  -  VW
        CW_ADV = -XI(I)/ADV**2
        CW_VW  =                  -  1.0
        CW_XW  =  0.0
cc      CW_XW  =   1.0 /ADV
C
        SW     = UTOTW + WA  +  VAW
        SW_ADW =                VAW_ADW
        SW_VW  =                VAW_VW
        SW_XW  =                VAW_XW
C
C
C------ enforce constant induced efficiency condition at Ith station
C
C------ Ei( Sw( Adw Vw Xw )  Cw( Adv Vw Xw )  Xw  Adv )
        EILOC  = ( SW/CW)*(XI(I)/ADV)
        EI_SW  = (1.0/CW)*(XI(I)/ADV)
        EI_CW  = -EILOC/CW
        EI_XW  = 0.0
ccc     EI_XW  = ( SW/CW)*( 1.0 /ADV)
        EI_ADV = -EILOC/ADV
C
C------ Ei( Vw  Xw  Adv Adw )
        EI_VW  = EI_SW*SW_VW  + EI_CW*CW_VW
        EI_XW  = EI_SW*SW_XW  + EI_CW*CW_XW  + EI_XW
        EI_ADV =                EI_CW*CW_ADV + EI_ADV
        EI_ADW = EI_SW*SW_ADW
C
        IF(EI_VW .EQ. 0.0) THEN
         DQ(I) = 0.0
         Q(I,I) = 1.0
        ELSE
C
        DQ(I) = EILOC - EFFINV
        DO J = 1, II
          Q(I,J) = EI_XW*XW_GAM(I,J) + EI_VW*VW_GAM(I,J)
        ENDDO
        Q(I,K1) = -1.0
        Q(I,K2) = EI_XW*XW_ADW(I) + EI_VW*VW_ADW(I)  +  EI_ADW
C
        ENDIF
C
        GRESMX = MAX( GRESMX , ABS(DQ(I)) )
  100 CONTINUE
C
      DO J=1, K2
        Q(K1,J) = 0.
        Q(K2,J) = 0.
      END DO
C
C---- thrust or power will be defined with equivalent prop
      IF(DEST) THEN
C
C----- drive thrust to specified value
       DQ(K1) = TWAK + TVIS - TDES
       DO J=1, II
         Q(K1,J) = TW_GAM(J) + TV_GAM(J)
       END DO
       Q(K1,K2) = TW_ADW + TV_ADW
C
       FRESMX = MAX( FRESMX , ABS(DQ(K1)/TDES) )
C
      ELSE IF(DESP) THEN
C
C----- drive power to specified value
       DQ(K1) = PWAK + PVIS - PDES
       DO J=1, II
         Q(K1,J) = PW_GAM(J) + PV_GAM(J)
       END DO
       Q(K1,K2) = PW_ADW + PV_ADW
C
       FRESMX = MAX( FRESMX , ABS(DQ(K1)/PDES) )
      ENDIF
C
      IF(FREE) THEN
C----- free wake option:
C----- set up equation to converge wake advance ratio
       DQ(K2) =  ADW*TINV/PINV     -  ADV
       Z_TI   =  ADW     /PINV   
       Z_PI   = -ADW*TINV/PINV**2
       DO J=1, II
         Q(K2,J) = Z_TI*TI_GAM(J) + Z_PI*PI_GAM(J)
       END DO
       Q(K2,K2) = Z_TI*TI_ADW + Z_PI*PI_ADW + TINV/PINV
C
       ARESMX = MAX( ARESMX , ABS(DQ(K2)/ADV) )
      ELSE
C----- specify zero change of wake advance ratio
       DQ(K2) = 0.
       Q(K2,K2) = 1.0
      ENDIF
C
C---- solve linearized Newton system
      CALL GAUSS(IQ,K2,Q(1,1),DQ(1),1)
C
C---- set under-relaxation parameter to prevent excessive circ. changes
      RLX = 1.0
      IF(NITERD.EQ.0) RLX = 0.0
      DO I=1, II
        DGAM(I) = -DQ(I)
C
        IF(RLX*DGAM(I)/GAM(I) .LT. -.5) RLX = -.5*GAM(I)/DGAM(I)
        IF(RLX*DGAM(I)/GAM(I) .GT. 0.5) RLX = 0.5*GAM(I)/DGAM(I)
      END DO
C
      DEFF = -DQ(K1)
      DADW = -DQ(K2)
C
C---- update circulation induced efficiency
      RMS = 0.
      GMX = 0.
      IMX = 0
      DO I=1, II
        GAM(I) = GAM(I) + RLX*DGAM(I)
C
        RMS = RMS + DGAM(I)**2
        IF(ABS(DGAM(I)) .GE. ABS(GMX)) THEN
         GMX = DGAM(I)
         IMX = I
        ENDIF
      END DO
      RMS = SQRT(RMS/FLOAT(II))
C
      EFFINV = EFFINV + RLX*DEFF
      ADW    = ADW    + RLX*DADW
C
cC---- display iteration history
c      WRITE(*,2100) ITER, GMX, IMX, RMS, 
c     &              EFFINV, ADW, RLX
c 2100 FORMAT(1X,I4,'   dG max(i),rms:',E11.3,' (',I2,')', E11.3,
c     &  '   Ei:',F12.5,'    Aw:',F12.5,'      RLX:',F7.4)
C
C
C---- test for convergence
      IF(MAX(RMS,ABS(DEFF),ABS(DADW)) .LE. 1.0E-05) THEN
C----- final update of various quantities corresponding to converged solution
C
       IF(FREE) THEN
        IF(FAST) THEN
          CALL GRADMO(IX,II, NBLDS, DUCT, RAKE,
     &                XI,XV,GAM, ADW,VIND_GAM,VIND_ADW) 
          IWTYP = 1
        ELSEIF(.NOT.VRTX) THEN
          CALL HELICO(IX,II, NBLDS, DUCT, RAKE,
     &                XI,XV,GAM, ADW,VIND_GAM,VIND_ADW) 
          IWTYP = 2
        ELSEIF(VRTX) THEN
          CALL VRTXCO(IX,II, NBLDS, DUCT, RAKE,
     &                XI,XV,GAM, ADW,VIND_GAM,VIND_ADW) 
          IWTYP = 3
        ENDIF
       ENDIF
C
       CALL VCALC
       CALL TPQ(ICASE)
C
       CONV = .TRUE.
       RETURN
      ENDIF
C
 1000 CONTINUE
C
      RETURN
      END ! DEITER



      SUBROUTINE SETCLD(CL1,CL2)
C---------------------------------------------
C     Sets design CL distribution as linear 
C     between CL1 at root and CL2 at tip
C---------------------------------------------
      INCLUDE 'XROTOR.INC'
C
      IF(CL1 .EQ. 999.0) THEN
C------ special option... read CL distribution from file
        LU = LUTEMP
C
 105    CALL ASKS('Enter CL specification filename^',FNAME)
        OPEN(LU,FILE=FNAME,STATUS='OLD',ERR=105)
        DO I=1, IX
          READ(LU,*,END=108) W1(I), W2(I)
        ENDDO
        WRITE(*,*) 'Too many file input points'
 108    N = I-1
        CLOSE(LU)
C
        CALL SEGSPL(W2,W3,W1,N)
        DO I=1, II
          CLDES(I) = SEVAL(XI(I),W2,W3,W1,N)
        ENDDO
C
      ELSE
C------ use linear prescribed CL
C
        DO I=1, II
          CLDES(I) = (1.0-XI(I))*CL1 + XI(I)*CL2
        ENDDO
C
      ENDIF
C
      RETURN
      END



      SUBROUTINE SAVCLD
C---------------------------------------------
C     Saves design CL distribution.
C---------------------------------------------
      INCLUDE 'XROTOR.INC'
      CHARACTER ANS*1
C
      LU = LUTEMP
 105  CALL ASKS('Enter CL specification output filename^',FNAME)
      IF(FNAME.EQ.' ') RETURN
C
C---- Check for old CLDES file
      OPEN(LU,FILE=FNAME,STATUS='OLD',ERR=10)
      WRITE(*,*)
      WRITE(*,*) 'CLDES file exists.  Overwrite ?  Y'
      READ (*,1000) ANS
 1000 FORMAT(A)
      IF(INDEX('Nn',ANS) .EQ. 0) GO TO 15
      WRITE(*,*) 'Blade CL not saved.'
      GO TO 200
C
 10   OPEN(LU,FILE=FNAME,STATUS='UNKNOWN',ERR=105)
 15   DO I=1, II
        WRITE(LU,*,ERR=108) XI(I), CLDES(I)
      ENDDO
      GO TO 200
C
 108  WRITE(*,*) 'Error writing CLDES file'
C
 200  CLOSE(LU)
C
      RETURN
      END




