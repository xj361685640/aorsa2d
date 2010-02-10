module eqdsk_setup_mod

    use parameters
    use aorsa2din_mod
    use aorsasubs_mod

    implicit none

    integer :: fcount, nmax, i_psi
    real :: xwleft, sgn_vprl, modb, bratio_phi, &
         dxdphi, dydphi, caprx, sigma, eps
    real, allocatable :: bxn(:,:), byn(:,:), bzn(:,:), &
            bmod(:,:),  bratio(:,:)
    real, allocatable  :: zbxn(:,:,:), zbyn(:,:,:), zbzn(:,:,:), &
            zbmod(:,:,:), zbratio(:,:,:)
    real :: s_err(100), y_phi(100)
    real :: rmaxis, zmaxis, &
        psio, psimag, psi_tor_max
    real :: bxn_eq(nxmx, nymx), byn_eq(nxmx, nymx), &
           bzn_eq(nxmx, nymx), bmod_eq(nxmx, nymx)
    real :: psi(nxmx, nymx), qsafety(nxmx, nymx)
    real :: bmod_mid(nxmx, nymx)
    real :: rho_pol2d(nxmx, nymx)
    real :: capr_bpol_mid2(nxmx, nymx)
    real :: capr_bpol_mid(nrhomax) 
    real :: rho_tor2d(nxmx, nymx)
    real :: dldb_tot12(nxmx, nymx)
    real :: dldbavg(nrhomax)
    real :: xMax, yMax

contains

      subroutine eqdsk_setup ()

      use orbit_mod
      use fitpack

      implicit none

      real, allocatable :: xprime(:), yprime(:) 
      real :: dx, dy
      integer dlg_yRange
      integer jmid
      integer  mmax, n_phi, n_phi_max
      integer icell, jcell, icell_prev, jcell_prev, ncell, i_stop
      real, allocatable :: rho_ij(:,:), rho_in(:), profile_in(:), &
         profile_out(:,:)

      integer i0_eq, j0_eq, ileft, iright, jtop, jbottom
      integer i_box, i_sgn_vprl, i_err, i_sav, j_sav, i0, j0, i_max
      integer imaxis, jmaxis

      real modb_init
      real xphi, yphi, phi, dy_phi(100)
      real h0,  delta_b, r_max, drg, dzg, drg32, dzg32
      real x_extint, y_extint, xprimex, yprimex, &
         xprimex0, yprimex0
      integer norb_dim, nphi_enter, nphi_exit, nphii
      integer islpsw, islpsw1, ierr, nrho
      real psix, psix_prev

      real betan3, betan_slo, betate, alphati6, betan, betan2, betan5, &
        betan6, betati4, betati, betati2, betan4, alphan3, alphan_slo, &
        alphan4, eta6, xnu6ad, alphan2, alphati3, alphati4, alphti5, &
        alphan5, alphan6, betati5, iql, i_antenna, antlc, &
        nzeta_wdot, n_bin, antlen, xkperp_cutoff, damping, xnu4ad, amu5, &
        z4, eta4, xnu5ad, amu6, z5, eta5, xn6lim, xnslo, xn4lim, xn5lim, &
        xn6, amu4, xn4, xn5, ndisti3, ndisti4, ndisti1, ndisti2, nkperp, &
        upshift, ndisti5, ndisti6, alphati5, betati6, z6, alphati2, &
        theta_ant, ndiste, betati3, taue, psipti5, psipti6, xn3lim, &
        xnslolim, freqcy, xn2lim, ti05, ti06, ti04, ti6lim, psipti4, &
        ti4lim, ti5lim

      integer i_write, nphi1, nphi2, nuper, nupar

      CHARACTER*128 :: netCDF_file

      parameter (norb_dim = 6000)

      real capr_x(norb_dim), capz_x(norb_dim), phin_x(norb_dim), &
         modb_x(norb_dim), dlen_x(norb_dim), dl_vprl(norb_dim), &
         dl_bratio(norb_dim), &
         dl_vprlh, len_x(norb_dim), length, length_prev
      real capr_x0, capz_x0
      real delta_x, delta_y, delta_z, delta_l, xprime_prev, delta_phi, &
         yprime_prev, phi_prev
      real yprime_want, dxdphi_prev, dydphi_prev
      real xprime_want

      integer npts, ndeg, lxdata, iout, lipwr, ndval, lenws
      integer nr, ntheta, nrmax, nthmax, neqdsk, meqdsk, nk, mk
      integer ma, mr, mz, ipsi, iflag_gammab, isolve

      integer nnode_local, nnode_overlap, iprofile
      real eslowev, ftrap, z_slo, yzoom1, psimol, yzoom2, &
         amu_slo, eta_slo, fmid

      integer idiag, jdiag, ieq
      integer ninteg, nd, izoom1, izoom2, ndf, nmaxe, irnc
      integer nrow, ncol, norder

      integer nkx1, nkx2, &
         nky1, nky2, iant, jant1, jant2

      real tmem, tsys, tio, ttotal, time0, time, cpu, dummy, second1
      real tmin, gflops, gflopsp, ops, teev, dum
      real sqx, gausspsi, dpsiant
      real dthetant0, dpsiant0, psiant, psipne, psipte, &
         psipti1, psipti2, psipti3, dtheta, rhomin
      real rmin, rmax, zmin, zmax, ro, zo

      integer n_u_max, n_theta_check
      parameter (n_u_max = 300)

      parameter (nrmax = 201)
      parameter (nthmax = 64)

      integer, parameter :: nxeqdmax = 200, nyeqdmax = 200

      parameter (lxdata = nxeqdmax * nyeqdmax)
      parameter (lipwr = 10)
      parameter (ndeg = 2)
      parameter (lenws = lxdata * (lxdata + 9) &
                        + lipwr * (lxdata + 1) + 2 * ndim)


      real zx1(nymx), zxm(nymx), zy1(nxmx), zyn(nxmx)
      real zxy11, zxym1, zxy1n, zxymn
     real zpsi(nxmx, nymx, 3)

      real temp(2 *(nxmx + nymx) )
      real surf2, curv2


!***   CQL3D arrays:

!      real u(n_u_max)
      real theta_(n_theta_max, n_psi_max)
      real sinth2_init(n_theta_max, n_psi_max)

!      real f_cql_2d(n_u_max, n_theta_max)
!      real f_cql_1d(n_u_max)

!      real f_cql(n_theta_max, n_u_max, n_psi_max)
!      real dfdu_cql(n_theta_max, n_u_max, n_psi_max)
!      real dfdtheta_cql(n_theta_max, n_u_max, n_psi_max)
!      real rho_a(n_psi_max)

      integer n_theta_(n_psi_max)

      real dtau(n_theta_max), dtau_tot(n_theta_max), &
         dtau_first(n_theta_max)

      real dtau_first_12, dtau_tot12
!      real dtau_ratio(nxmx, nymx, n_theta_max)
!      real tau_bounce(nxmx, nymx, n_theta_max)

      real dtau_tot1(n_theta_max), dtau_first1(n_theta_max)
      real dtau_tot2(n_theta_max), dtau_first2(n_theta_max)

      integer n_theta, n_u, n_psi
      integer i_theta, i_u
      real vc, vc_mks, sinthi, modbi, argi, vprl, dtau_sum, modbh, &
         dtau_tot_sum, dldb_tot_sum, dldb_tot1, dldb_tot2



!***  EQDSK arrays:

      real rhoeqdsk(nxeqdmax), psigrid(nxeqdmax), agrid(nxeqdmax), &
         fpsi(nxeqdmax), dfpsida(nxeqdmax), &
         qpsi(nxeqdmax), dqpsida(nxeqdmax)

      real rho_tors(nxeqdmax)

      real psis(nxeqdmax), fs(nxeqdmax), fs1(nxeqdmax)
      real qs(nxeqdmax), qs1(nxeqdmax)
      real rg(nxeqdmax), zg(nyeqdmax), psig(nxeqdmax, nyeqdmax)
      real psirg(nxeqdmax, nyeqdmax), psizg(nxeqdmax, nyeqdmax)
      real psirzg(nxeqdmax, nyeqdmax), psig2(nxeqdmax, nyeqdmax)

      double precision xdata(lxdata, 2), ydata(lxdata)
      double precision stats(8), cval(lxdata), dval(lipwr)
!      double precision ws(lenws)
      integer ipwr(lipwr, 2)


      real capr_eqdsk(nrmax, nthmax), &
           capz_eqdsk(nrmax, nthmax), &
           bmod_eqdsk(nrmax, nthmax)

      real bx_eqdsk(nrmax, nthmax), &
           by_eqdsk(nrmax, nthmax), &
           bz_eqdsk(nrmax, nthmax), &
           drdth_eqdsk(nrmax, nthmax), &
           dzdth_eqdsk(nrmax, nthmax)

      real rho_eqdsk(nrmax), &
           theta_eqdsk(nthmax)

      real psisep, router, z0
      integer nxeqd, nyeqd

      real dzdrhok, dzdthk, drdrhok, drdthk, xjacob

      real dbdrhok, dbdthk, &
           dbxdrhok, dbxdthk, &
           dbydrhok, dbydthk, &
           dbzdrhok, dbzdthk

      real rhok, thetak, theprm, rho1, bmodk, bxk, byk, bzk, psi1
      real xk(nxmx), yk(nymx)
      real bmod_eqdskk

      real rho_lim, rhowall
      real diffx, diffy, diff, diffmin
      integer neqdsk_min, meqdsk_min, ik, jk


      complex s(nldim3) , t(nldim3), q1(nldim3)
      integer info
      complex b, zi, cexpkxky

      complex fdk, fek, ffk, fgk, fak, fpk, frk, fqk, fsk


      real xkxsav(nkdim1 : nkdim2), xkysav(mkdim1 : mkdim2), &
           xkperp, xketa, &
           xkprl, ptot, pcito2, pcrto2, powtot, pscale, &
           cosalp, sinalp, t1, gaussian, frho, q07qa, psimax, &
           rhomax, xnprl, rhoant, gaussantx, gaussanty, &
           dthetant, gaussantth, xnuomg, gaussiant


      integer nmodesx, nmodesy, nwdot, lmax, ibessel, &
          inu, iprint, iexact, &
          iroot, iequat, igeom, &
          iqx, iqprof, iez, icurve, izfunc, &
          nstep, nabs, &
          isigma, itemp, &
          nfreqm,  nkzm, &
          idens,  ibackground, iabsorb, &
          nzfun, nnodecx, nnodecy, i, j, &
          jequat, iflag, liw, lw, nrhs, icenter, nboundary

      integer nnoderho

      integer n, m, nphi

      real ti0, xnuead, xnu1ad, xnu2ad, xant, te0, &
          delta0, xwall, xnwall, delta, &
          epszet, amu1, amu2, z1, z2, eta, &
          xnurf, aplasm, xnlim, signbz, &
          xn0, flat, b1rat, b2rat, curdnx, curdny, curdnz, &
          xnuabs, xbnch, xleft, xright, &
          telim, tilim, ti2lim, ti3lim, rhoplasm, &
          alphan, alphate, alphati, &
          dfreq,  dkz, reomg1, reomg2, reomg3, &
          r0, xnudip, adip, efold, &
          amu3, z3, eta3, xnu3ad, &
          xdelta, wdelta, xdelt2, wdelt2, zeffcd, &
          rzoom1, rzoom2, q0, prfin, &
          alim, grad, qavg0, &
          rhonorm, ekappa, xiota0, rholim, psilim, psilim_, yant, &
          xwright, psi_lim, &
          rwleft_auto, rwright_auto, ytop_auto, ybottom_auto

      real ytop_max, ybottom_max

      real xkphi(nxmx), xktau, xkrho, rant, xkphi0, xnphi
      real rplasm, rlim

      real xkthrho, wphase, vsound, domgk, xkthdx, omgestar, rhoi10, &
         v0i, vthi10, vthe, vthi, vphase, rnz, xn2, eta2, &
         xk0, shearedge, eta1, xn1, xmi1, xmh, xme, qi1, xmi2, &
         xmi3, t0i, t0i2, t0i3, t0e, q, teedge, clight, xmu0, xlnlam, &
         omgci10, omgrf, qe,i3, qi2, pi, eps0, xn3, qi3, &
         costh, sinth, radius, rnx,  rny, rnphi, ti02, ti03, twopi

      real xjantx, xjanty, xjantz, xjant
      real xjx(nxmx, nymx), xjy(nxmx, nymx), xjz(nxmx, nymx)
      complex xb(nxmx, nymx), xc(nxmx, nymx), xd(nxmx, nymx)

      real xprimec(nxmx), caprc(nxmx), xcourse(nxmx), capr(nxmx), &
          x(nxmx), dxc


      real capr_bpol(nxmx, nymx)

      real bxn_eq(nxmx, nymx), byn_eq(nxmx, nymx), &
           bzn_eq(nxmx, nymx), bmod_eq(nxmx, nymx)

      real psizz(nxmx, nymx), psirr(nxmx, nymx), psirz(nxmx, nymx)
      real work(nxmx, nymx)


      real rhon(nrhomax), wdoti1avg(nrhomax), wdoti2avg(nrhomax), &
         wdoteavg(nrhomax), drho, dvol(nrhomax), fvol(nrhomax), &
         bmod_midavg(nrhomax)

      real dvol_xy(nrhomax), dvol_dl(nrhomax)
      real xnavg(nrhomax), fyavg(nrhomax), qhat, omgte, omgti, &
           vthe0, vthi0, xnuee, xnuii, xnu7omg

      real redotj1avg(nrhomax), redotj2avg(nrhomax), &
           redotjeavg(nrhomax), redotj3avg(nrhomax), &
           redotjtavg(nrhomax)

      real fypavg(nrhomax), fypi1avg(nrhomax), fypi2avg(nrhomax)
      real vyavg(nrhomax),  vyi1avg(nrhomax),  vyi2avg(nrhomax)
      real xnupiavg(nrhomax), rhomavg(nrhomax)
      real dvydrho(nrhomax)

      real psi_dim(nxmx, nymx)


      real  rho(nxmx, nymx), theta(nxmx, nymx), &
           theta0(nxmx, nymx), &
           bx(nxmx, nymx), by(nxmx, nymx), bz(nxmx, nymx), &
           btau(nxmx, nymx), bzeta(nxmx, nymx), &
           dxdth(nxmx, nymx), dzdth(nxmx, nymx), xntau(nxmx, nymx), &
           xn(nxmx, nymx), xkte(nxmx, nymx), xkti(nxmx, nymx), &
           xkti2(nxmx, nymx), xkti3(nxmx, nymx), &
           xn1a(nxmx, nymx), xnea(nxmx, nymx), xn2a(nxmx, nymx), &
           xn3a(nxmx, nymx), omgce(nxmx, nymx), &
           omgci1(nxmx, nymx), omgci2(nxmx, nymx), omgci3(nxmx, nymx), &
           omgpe2(nxmx, nymx), &
           omgp12(nxmx, nymx), omgp22(nxmx, nymx), omgp32(nxmx, nymx), &
           xiota(nxmx, nymx),  xlprl(nxmx, nymx), &
           bpol(nxmx, nymx)

      real psi_tor2d(nxmx, nymx), psi_pol2d(nxmx, nymx)

      real rhomtot(nxmx, nymx), rhome, rhomi1, rhomi2, rhomi3
      real xnupi(nxmx, nymx), prod


      real dbxdx(nxmx, nymx), dbydx(nxmx, nymx), dbzdx(nxmx, nymx), &
           dbxdy(nxmx, nymx), dbydy(nxmx, nymx), dbzdy(nxmx, nymx), &
           dbdx(nxmx, nymx),  dbdy(nxmx, nymx)

      real gradprlb(nxmx, nymx)

      real dxxbxn(nxmx, nymx), dxxbyn(nxmx, nymx), dxxbzn(nxmx, nymx), &
           dxybxn(nxmx, nymx), dxybyn(nxmx, nymx), dxybzn(nxmx, nymx), &
           dyybxn(nxmx, nymx), dyybyn(nxmx, nymx), dyybzn(nxmx, nymx), &
           dxxmodb(nxmx, nymx), dxymodb(nxmx, nymx), dyymodb(nxmx, nymx)


      complex ex(nxmx, nymx), ey(nxmx, nymx), ez(nxmx, nymx)
      complex dezdx, dezdy, deydx, dexdy
      complex adisp(nxmx, nymx), acold(nxmx, nymx)

      complex bxwave(nxmx, nymx), bywave(nxmx, nymx), bzwave(nxmx, nymx)
      real spx(nxmx, nymx), spy(nxmx, nymx), spz(nxmx, nymx)


      complex ealpha(nxmx, nymx), ebeta(nxmx, nymx), eb(nxmx, nymx)


      real pcedotj1, pcedotje, pcedotj2, pcedotjt, pcedotj3
      real pedotj1, pedotje, pedotj2, pedotjt, pedotj3

      real p, pi1, pi2, pit, pi3, pe

      complex sigexx, sigexy, sigexz, &
              sigeyx, sigeyy, sigeyz, &
              sigezx, sigezy, sigezz

      complex sig1xx, sig1xy, sig1xz, &
              sig1yx, sig1yy, sig1yz, &
              sig1zx, sig1zy, sig1zz

      complex sig2xx, sig2xy, sig2xz, &
              sig2yx, sig2yy, sig2yz, &
              sig2zx, sig2zy, sig2zz

      complex sig3xx, sig3xy, sig3xz, &
              sig3yx, sig3yy, sig3yz, &
              sig3zx, sig3zy, sig3zz


      complex &
           sigxx, sigxy, sigxz, &
           sigyx, sigyy, sigyz, &
           sigzx, sigzy, sigzz

      complex &
           xkxx, xkxy, xkxz, &
           xkyx, xkyy, xkyz, &
           xkzx, xkzy, xkzz
      complex scap, scold

      complex xk1xx, xk1xy, xk1xz, &
              xk1yx, xk1yy, xk1yz, &
              xk1zx, xk1zy, xk1zz

      complex xk2xx, xk2xy, xk2xz, &
              xk2yx, xk2yy, xk2yz, &
              xk2zx, xk2zy, xk2zz


      complex &
           dxx, dxy, dxz, &
           dyx, dyy, dyz, &
           dzx, dzy, dzz

      complex &
           bxx, bxy, bxz, &
           byx, byy, byz, &
           bzx, bzy, bzz

      complex sk1, sk2, sk3, sk4, sk5, sk0

      real yprimec(nxmx), ycourse(nxmx), &
           y(nxmx), dyc


      CHARACTER*128 :: eqdsk




!     ------------------------------
!     storage for parallel scalapack
!     ------------------------------
      INTEGER            DLEN_
      PARAMETER          ( DLEN_ = 9 )
      INTEGER            CTXT_, M_, N_, MB_, NB_
      PARAMETER          ( CTXT_ = 2, M_ = 3, N_ = 4, MB_ = 5, NB_ = 6 )
      INTEGER            RSRC_, CSRC_, LLD_
      PARAMETER          ( RSRC_ = 7, CSRC_ = 8, LLD_ = 9 )


      integer icnc
      logical ismine, ismine1, ismine2, ismine3

!      integer numroc
!      external numroc
      integer lld,nrow_local,ncol_local

      character*4 suffix

      integer mb,nb,myid,nproc,wantnproc,myrow,mycol
      integer nprow,npcol,icontxt, wantnprocs
      integer lrindx,lcindx,rsrc,csrc,ipos,ii,jj
      integer desc_amat(dlen_), desc_brhs(dlen_)

      integer rsrc1, csrc1, irnc1, icnc1
      integer rsrc2, csrc2, irnc2, icnc2
      integer rsrc3, csrc3, irnc3, icnc3

      allocate ( bxn(nxmx, nymx), byn(nxmx, nymx), bzn(nxmx, nymx), &
            bmod(nxmx, nymx),  bratio(nxmx, nymx),  &
            zbxn(nxmx, nymx, 3), zbyn(nxmx, nymx, 3), zbzn(nxmx, nymx, 3), &
            zbmod(nxmx, nymx, 3), zbratio(nxmx, nymx, 3), &
            xprime(nxmx), yprime(nxmx) )



!--set default values of input data:


      nboundary = 1
      nprow = 8
      npcol = 8

      nwdot = 0
      nnodecx = nmodesmax
      nnodecy = mmodesmax
      lmax = 5
      ibessel = 1
      !xnuomg = 0.0

      xnuead = 0.0000E+00
      xnu1ad = 0.0000E+00
      xnu2ad = 0.0000E+00
      rant = 1.6

      dthetant0 = 60.
      dpsiant0 = .05

      psilim = 1.0
      psilim_= 0.99
      psiant = 0.95
      psipne = 0.50
      psipte = .30
      psipti1 = .30
      psipti2 = .30
      psipti3 = .30

      yant = .1

      te0  = 4.2900E+03
      ti0  = 7.0700E+03
      ti02 = 7.0700E+03
      ti03 = 7.0700E+03

      inu = 0
      iprint = 50
      iexact = 1
      delta0 = 0.0000E+00
      xwall = 0.0000E+00
      iroot = 2
      iequat = 1
      igeom = 5
      epszet = 1.0000E-07
      iqx = 4
      iqprof = 1
      iez = 0
      icurve = 2
      nphi = 33
      amu1 = 2.0000E+00
      amu2 = 1.0000E+00
      z1 = 1.0000E+00
      z2 = 1.0000E+00
      eta = 4.5000E-01
      b0 = 2.08
      q0 = 1.0
      rt = 1.68
      ekappa = 2.0
      ymax = 0.0
      xnurf = 3.2000E+07
      aplasm = 7.0000E-01
      alim = 100.0
      grad = 0.0

      signbz = 1.0000E+00
      xn0 = 3.1100E+19
      flat = 0.0000E+00
      b1rat = 7.0000E-01
      b2rat = 1.3000E+00
      curdnx = 0.0000E+00
      curdny = 1.0
      curdnz = 0.0000E+00
      prfin = 0.0
      nstep  = 16
      nabs = 2
      xnuabs = 0.0000E+00
      xbnch = 0.0000E+00
      xleft = -7.000E-01
      xright = 7.0000E-01
      isigma = 1
      nzfun = 1
      qavg0 = 1.0
      iabsorb = 2
      itemp = 0

      xnlim  = 0.0000E+00
      telim  = 0.0000E+00
      tilim  = 0.0000E+00
      ti2lim = 0.0000E+00
      ti3lim = 0.0000E+00


      nfreqm = 1
      dfreq = 0.0000E+00
      nkzm = 1
      dkz = 0.0000E+00
      idens = 0
      r0 = 2.3000E+00
      xnudip = 2.5000E+00
      adip = 0.0000E+00
      efold = 0.0000E+00
      amu3 = 1.2000E+01
      z3 = 6.0000E+00
      eta3 = 4.6600E-02
      xnu3ad = 0.0000E+00
      xdelta = 5.5000E-01
      wdelta = 0.0000E+00
      xdelt2 = -7.000E-02
      wdelt2 = 0.0000E+00
      zeffcd = 2.5000E+00
      rzoom1 = 0.0
      rzoom2 = 0.0
      ibackground = 1


      alphan = 1.0
      alphate = 1.0
      alphati = 1.0
      idiag = 5
      jdiag = 4





      if (myid .eq. 0) then
        open(unit=138,file='out138',status='unknown',form='formatted')
!        open(unit=115,file='out115',status='unknown',form='formatted')
      end if



      nrhs = 1
      nmaxe=1


!-----nmodesx=number of modes used in the x direction
!-----nmodesy=number of modes used in the y direction
!-----nwdot=number of radial modes used in wdot and flow (fy) calculation
!-----nnodecx = number of radial mesh points used for wdot calculation
!-----nnodecy = number of vertical mesh points used for wdot calculation

!-----ibessel=flag determining whether or not to expand ion Bessel functions
!           if(ibessel.eq.1) Full Bessel functions and exponential are used
!           if(ibessel.eq.2) Exact 2nd order expansion from finite difference
!                            code is used
!           if(ibessel.eq.3) 2nd order Larmor radius expansion of Bessel
!                            functions is used with exponential = 1.0

!-----lmax = highest order Bessel function kept in plasma conductivity
!-----ti0=central value of ion temperature in eV
!-----nuead=ad hoc collision frequency for electron in sec-1
!-----nu1ad=ad hoc collision frequency for majority ions in sec-1
!-----nu2ad=ad hoc collision frequency for minority ions in sec-1
!-----rant = major radius of antenna in meters

!-----yant = half height of antenna in meters
!-----te0=central value of eletron temperature in eV

!-----inu:   if(inu.eq.0)real collisions are left out
!-----iprint:  output is printed every iprint grid points
!-----iexact:  if (iexact.eq.1) full sixth order equation is solved
!-----         if (iexact.eq.0) approximate second order equation is solved
!-----delta0=numerical damping for Bernstein wave:  about 1.e-04 (dimensionless)
!-----xwall = not used

!-----iroot: decides which of the two fast wave roots to follow
!-----iequat:  if(iequat.eq.1) complete equations are solved
!-----         if(iequat.eq.2) Fukayama's equations are solved

!-----igeom: if(igeom.eq.1)not used
!-----       if(igeom.eq.2)Solovev flux surfaces
!-----       if(igeom.eq.5) GA - EQDSK surfaces are used.
!-----       if(igeom.eq.6) ORNL - EQDSK surfaces are used.
!
!-----nboundary: if(nboundary .eq. 1)flux surface boundary (default)
!-----           if(nboundary .eq. 0)square boundary
!
!-----epszet=error criterion for Z function calculation if disp is used

!-----iqx:  if(iqx.eq.1) Vaclavik's  kinetic flux is used
!-----      if(iqx.eq.2) Romero's  kinetic flux is used
!-----      if(iqx.eq.3) Jaeger's  kinetic flux is used
!-----      if(iqx.eq.4) Batchelor's  kinetic flux is used (reduces to WKB)
!-----iqprof: if(iqprof.eq.1) q profile is proportional to density (default)
!-----        if(iqprof.eq.2) q profile is proportional to sqrt(density)
!-----iez:  if(iez.eq.0) Ez is calculated from complete equation
!-----      if(iez.eq.1) Ez is set to zero

!-----icurve: if(icurve .eq. 0)antenna is straight in poloidal direction
!.                and located at rant
!-----        if(icurve .eq. 2)antenna follows flux surface and is
!                located at psiant

!-----nphi = toroidal mode number (integer)
!-----amu1= ratio of majority ion to hydrogen ion mass
!-----amu2= ratio of minority ion to hydrogen ion mass
!-----z1=ratio of majority ion charge to hydrogen ion charge
!-----z2=ratio of minority ion charge to hydrogen ion charge
!-----eta=ratio of minority ion density to electron density


!-----b0=value of magnetic field at x=0 in Tesla
!-----q0=value of inverse rotational transform on axis
!-----rt= major radius of torus
!-----ekappa = elongation
!-----rwleft = major radius of the left conducting boundary
!-----rwright = major radius of the right conducting boundary
!-----ytop = y value for top boundary
!-----ytop = y value for bottom boundary
!-----ymax = radius in vertical (y) direction- in default it is set to awallx
!-----xnurf= rf frequency in Hertz
!-----aplasm= location of the plasma-scrape-off interface
!-----alim = location of limiter
!-----grad = 0.0 ignors gradients in Wdot (default)
!-----grad = 1.0 includes gradients in Wdot
!-----xnlim=electron density in scrape-off region (x>aplasm)
      if(abs(signbz).lt.1.0e-05)signbz = +1.0

!-----xn0=electron density at x=0
!-----flat=0.0 gives parabolic profiles
!-----flat=1.0 gives flat profiles
!-----b1rat= low field value in step function magnetic field
!-----b2rat=high field value in step function magnetic field
!-----curdnx=Amps/meter of toroidal length of antenna in the x direction
!-----curdny=Amps/meter of toroidal length of antenna in the y direction
!-----curdnz=Amps/meter of toroidal length of antenna in the z direction
!-----prinf = total applied RF power


!-----nstep: determines steepness of step function magnetic field in option
!-----nabs=polynomial coefficient which determines slope of the absorber
!-----xnuabs=magnitude of absorber used to stop wall reflections in benchmark case.
!-----xbnch:  abs(x)>xbnch is the artificial absorber region to stop wall reflections
!        in benchmark case.
!-----if (xbnch.eq.0.0) it is ignored.
!-----xleft=left boundary for energy integrals and outgoing energy flux
!-----xright=right boundary for energy integrals and incoming energy flux

!-----if(iabsorb.eq.1)electron absorption from simple Landau formula
!-----if(iabsorb.eq.2)electron absorption from  .5 * real(J* dot E) i.e. ECH

!-----if(isigma.eq.0) cold plasma conductivity is used.
!-----if(isigma.eq.1) hot  plasma conductivity is used (default).

!-----nzfun:  if(nzfun.eq.0) Simple Z function is used from ZFUN
!-----        if(nzfun.ge.1) Generalized Z function of Brambilla is used (default).

!-----qavg0 is the rotational transform on axis
!-----xnuomg is the collison rate used in hot and cold plasma dielectrics

!-----if(itemp.eq.0)use Gaussian temperature-finite at edge-use with nlim=0 at edge
!-----if(itemp.eq.1)use Fukuyama's profile for temperature with c=-2 and d=1 -use
!          with nlim=finite at edge
!-----if(itemp.eq.2)use Gaussian times 1-r**2/xant**2
!-----telim=electron temperature in scrape-off region (x>aplasm)
!-----tilim=ion temperature in scrape-off region (x>aplasm)

!-----nfreqm=number of frequencies run
!-----dfreq=frequency increment
!-----nkzm=number of kz's run
!-----dkz=kz increment

!-----if(idens.eq.0)use parabolic density profile
!-----if(idens.eq.1)use D'Ippolito density profile
!-----r0 is parameter r0 in D'Ippolito density profile
!-----xnudip is parameter nu in D'Ippolito density profile
!-----adip is parameter nu in D'Ippolito density profile
!-----efold is the number of e-foldings in density between
!          plasma edge and awall = awallx

!-----amu3=ratio of third ion mass to hydrogen ion mass
!-----z3=ratio of third ion charge to hydrogen ion charge
!-----eta3=ratio of third ion density to electron density
!-----xnu3ad=ad hoc collision frequency for 3rd ion species

!-----xdelta=center of Gaussian for numerical damping of IBW
!-----wdelta=width of Gaussian for numerical damping of IBW
!-----xdelt2=second center of Gaussian for numerical damping of IBW
!-----wdelt2=second width of Gaussian for numerical damping of IBW
!-----zeffcd=Zeff for Ehst-Karney current drive calculation
!-----rzoom1 = R on left side of zoomed plot
!-----rzoom2 = R on right side of zoomed plot
!-----ibackground controls color of plotting window and labels
!-----    For white background set ibackground = 0 (box is black)
!-----    For black background set ibackground = 1 (box is red)

      nkx2 = nmodesx / 2
      nkx1 = - nmodesx / 2 + 1
      nmodesx = nmodesx
      nnoderho = nmodesx / 2

      nky2 = nmodesy / 2
      nky1 = - nmodesy / 2 + 1
      nmodesy = nmodesy

!      jequat  = nmodesy / 2
      icenter = nmodesx / 2

      if (qavg0 .ne. 0.0) xiota0 = 1./qavg0

      q = 1.6e-19
      if(te0 .eq. 0.0)te0 = ti0

      t0e = te0
      t0i = ti0
      t0i2 = ti02
      t0i3 = ti03


      teedge = 400.0

!      write (6, 101) nkx1, nkx2
!      write (6, 101) nky1, nky2
  101 format (10i10)



!      write(29,1000)nkzm

      qhat = qavg0


      t0e = t0e   * q
      t0i = t0i   * q
      t0i2 = t0i2 * q
      t0i3 = t0i3 * q

      telim   = telim  * q
      tilim   = tilim  * q
      ti2lim  = ti2lim * q
      ti3lim  = ti3lim * q


      teedge = teedge * q

      xme = 9.11e-31
      xmh = 1.67e-27
      xmi1 = amu1 * xmh
      xmi2 = amu2 * xmh
      xmi3 = amu3 * xmh
      qi1 = z1 * q
      qi2 = z2 * q
      qi3 = z3 * q
      qe = -q
      zi = cmplx(0.0,1.0)
      eps0 = 8.85e-12
      pi = 3.141592654
      twopi = 2.0 * pi
      xlnlam = 20.0
      xmu0 = 1.26e-06
      clight = 1.0 / sqrt(eps0 * xmu0)



      xkphi0 = nphi / rt



      omgrf = 2.0 * pi * xnurf
      omgci10 = qi1 * b0 / xmi1
      vthi10 = sqrt(2.0 * t0i / xmi1)
      v0i = vthi10
      rhoi10 = vthi10 / omgci10

      vphase = omgrf / xkphi0
      vthe = sqrt(t0e / xme)
      vsound = sqrt(teedge / xmi1)
      wphase = 0.0
      if(vthe .ne. 0.0)wphase = vphase / vthe


      xkthrho = 0.2
      xkthdx = 1.0


      xk0 = omgrf / clight
      rnz = xkphi0 / xk0
      xn1 = xn0 / z1 * (1.0 - z2 * eta - z3 * eta3)
      eta1 = xn1 / xn0
      xn2 = xn0 * eta
      eta2 = xn2 / xn0
      xn3 = xn0 * eta3

      allocate(rho_ij(nmodesx,nmodesy))

!      write (6, *) "eqdsk = ", eqdsk
!      write (6, *) "nmodesx = ", nnodex
!      write (6, *) "nmodesy = ", nmodesy
!      write (6, *) "rwleft = ", rwleft
!      write (6, *) "rwright = ", rwright
!      write (6, *) "ytop = ", ytop
!      write (6, *) "ybottom = ", ybottom

!      write (115, *) "eqdsk = ", eqdsk
!      write (115, *) "nmodesx = ", nnodex
!      write (115, *) "nmodesy = ", nmodesy
!      write (115, *) "rwleft = ", rwleft
!      write (115, *) "rwright = ", rwright
!      write (115, *) "ytop = ", ytop
!      write (115, *) "ybottom = ", ybottom

!     ------------------------------
!      read cql3d data in u and theta
!     ------------------------------

!      read (39, 9311) n_u
!      read (39, 9311) n_psi
!      read (39, 310) vc

!        read (39, 310) (u(i_u), i_u = 1, n_u)
!      read (39, 9311) (n_theta_(i_psi), i_psi = 1, n_psi)
!        read (39, 310) ((theta_(i_theta, i_psi),
!     .         i_theta = 1, n_theta_(i_psi)), i_psi = 1, n_psi)

!        read (39, 310) (rho_a(i_psi), i_psi = 1, n_psi)


      vc_mks = vc * 1.0e-02

!     ---------------------
!      Write some CQL3D data
!     ---------------------

!      WRITE (115,*)
!      WRITE (115,*) "n_theta_max = ", n_theta_max
!      WRITE (115,*) "n_u = ", n_u
!      WRITE (115,*) "n_psi = ", n_psi
!      WRITE (115,*) "n_theta_(i) = ", n_theta_
!      WRITE (115,*) "vc = ", vc
!      WRITE (115,*) "vc_mks = ", vc_mks, "m/sec"



!      WRITE(115,*)

!      write(115, *)
!      write(115, *) "rho/a(i_psi)"
!      write(115, 310) (rho_a(i_psi), i_psi = 1, n_psi)

!      write(115, *)
!      write(115, *) "u(i_u) ="
!      write(115, 310) (u(i_u), i_u = 1, n_u)


      i_psi = 5
!      write(115, *)
!      write(115, *) "theta(i_theta, 5) = "
!      write(115, 310)(theta_(i_theta, i_psi),i_theta =1,n_theta_(i_psi))









!     ------------------------------
!     Read in EQDSK information
!     ------------------------------

      call readeq_ga(nxeqdmax, nyeqdmax, rhoeqdsk, &
         psigrid, agrid, psimag, psisep, &
         rmin, rmax, zmin, zmax, rmaxis, zmaxis, b0, &
         rg, zg, psig, nxeqd, nyeqd, fpsi, &
         psio, ro, zo, qpsi, eqdsk, psi_tor_max)

      psig2 = psig
      if(psig(nxeqd/2, nyeqd/2) .lt. 0.0) psig2 = -psig


      drg = rg(2) - rg(1)
      dzg = zg(2) - zg(1)

      drg32 = (rg(nxeqd) - rg(1)) / 32.
      dzg32 = (zg(nyeqd) - zg(1)) / 32.

      imaxis = (rmaxis - rg(1)) / (drg) + 1
      jmaxis = (zmaxis - zg(1)) / (dzg) + 1


!     ----------------------------------
!     Find  rwright_auto and rwleft_auto
!     ----------------------------------

      j = jmaxis
      rwleft_auto = 0.0
      rwright_auto = 0.0

      do i = 2, nxeqd
       if (psig2(i,j) .gt. 0. .and. psig2(i-1,j) .lt. 0.) &
                                                    rwleft_auto= rg(i)
       if (psig2(i,j) .lt. 0. .and. psig2(i-1,j) .gt. 0.) &
                                                    rwright_auto=rg(i)
      end do



!     ---------------------
!     Find ytop and ybottom
!     ---------------------

      i = imaxis * .7

      ytop_auto = 0.0
      do j = nyeqd/2, nyeqd
       if (psig2(i,j) .lt. 0. .and. psig2(i,j-1) .gt. 0.) &
                                                      ytop_auto = zg(j)
      end do

      ybottom_auto = 0.0
      do j = 2, nyeqd / 2
        if (psig2(i,j) .gt. 0. .and. psig2(i,j-1) .lt. 0.) &
                                                   ybottom_auto = zg(j)
      end do

!     -------------------------
!     adjust boundaries outward
!     -------------------------
      ytop_auto    = ytop_auto    + dzg32
      ybottom_auto = ybottom_auto - dzg32
      rwright_auto = rwright_auto + drg32 * 2.0
      rwleft_auto  = rwleft_auto  - drg32 * 2.0

      if(ytop .eq. 0.0)    ytop = ytop_auto
      if(ybottom .eq. 0.0) ybottom = ybottom_auto
      if(rwleft .eq. 0.0)  rwleft = rwleft_auto
      if(rwright .eq. 0.0) rwright = rwright_auto

      ! DLG
      ! use entire vertial eqdsk box range instead
      if (eqdsk_zRange) then 
        ytop  = zmax
        ybottom   = zmin
      endif
      if (eqdsk_rRange) then 
        rwright  = rmax
        rwleft   = rmin
      endif

      xmax = rwright - rwleft
      ymax = ytop - ybottom

      do i = 1, nxeqd
         do j = 1, nyeqd
            call deriv_r(psig, nxeqdmax, nyeqdmax, i, j, nxeqd, nyeqd, &
                rg, psirg(i,j), dum)
            call deriv_z(psig, nxeqdmax, nyeqdmax, i, j, nxeqd, nyeqd, &
                zg, psizg(i,j), dum)
         end do
      end do


!      write(6, 309) nxeqd, nyeqd
!      write(6, 310) (rg(i), i = 1, nxeqd)
!      write(6, 310) (zg(j), j = 1, nyeqd)



!      do i = 1, nxeqd
!         write(6, 1312)i, rg(i), psig(i, nyeqd/2),
!     .        psirg(i, nyeqd/2), psizg(i, nyeqd/2), psirzg(i, nyeqd/2)
!      end do


!      write(6, 310)rmin, rmax, zmin, zmax
!      write(6, 310)psimag, psisep, psio



!      write(6, 1312)nxeqd
      do i = 1, nxeqd
         call deriv_x_eq(fpsi, agrid, nxeqdmax, i, nxeqd, dfpsida(i))
         call deriv_x_eq(qpsi, agrid, nxeqdmax, i, nxeqd, dqpsida(i))
!         write(6, 1312)i, agrid(i), fpsi(i), dfpsida(i)
      end do

!----------------------------------
!     Translate to DCON quantities:
!----------------------------------
      mr = nxeqd
      mz = nyeqd
      ma = nxeqd

      do ipsi = 1, ma
         psis(ipsi) = agrid(ipsi)
         fs(ipsi) = abs(fpsi(ipsi))
         fs1(ipsi) = abs(dfpsida(ipsi))

         qs(ipsi) = qpsi(ipsi)
         rho_tors(ipsi) = rhoeqdsk(ipsi)

         qs1(ipsi) = dqpsida(ipsi)

         if(myid .eq. 0)write(6, 1312) ipsi, psis(ipsi), rho_tors(ipsi)
      end do

      r0 = rmaxis
      z0 = zmaxis
      rt = r0


      xwleft = rwleft - rt
      xwright = rwright - rt


!--------------------------------------------
!--   Define x mesh: x(i), xprime(i), capr(i)
!--------------------------------------------
!--   xprime: 0 to xmax
!--   x(i) : -xmax / 2.0   to   xmax / 2.0
      dx = xmax / nmodesx

      diffmin = 1.0e+05

      do i = 1, nmodesx
         xprime(i) = (i - 1) * dx &
            + dx / 2.0
!--   Note: the code gives slightly smoother results with dx/2.0 added
         x(i) = xprime(i) + xwleft
         capr(i) = rt + x(i)

         xkphi(i) = nphi / capr(i)

       diff = abs(capr(i) - r0)
       if(diff .lt. diffmin) then
          diffmin = diff
          i0 = i
       end if

!         write(6, 1314)i, i0, xprime(i), x(i), capr(i), diff

      end do


      diffmin = 1.0e+05

!-----------------------------------
!     Define y mesh: y(j), yprime(j)
!-----------------------------------
!--   yprime: 0 to ymax
!--   y(j) : -ymax / 2.0   to   ymax / 2.0
      dy = ymax / nmodesy


      do j = 1, nmodesy
         yprime(j) = (j - 1) * dy &
            + dy / 2.0
!--      Note: the code gives slightly smoother results with dy/2.0 added
         y(j) = yprime(j) + ybottom

       diff = abs(y(j) - z0)
       if(diff .lt. diffmin) then
          diffmin = diff
          j0 = j
       end if

!         write(6, 1314)j, j0, yprime(j), y(j), diff, z0
      end do

      jmid = j0
      jequat = jmid

      if(myId==0)write(*,'(16f6.3)') capR(1:nmodesx)
      if(myId==0)write(*,'(16f6.3)') y(1:nmodesy)
      if(myId==0)write(*,'(16f6.3)') rmin,rmax,zmin,zmax,dx,dy

!      write(6, *)"jequat = ", jequat



!-----------------------------
!     Define rho mesh: rhon(n)
!------------------------------
!--   rhon: 0 to rhomax
      rhomax = 1.0
      drho = rhomax / (nnoderho - 1)
      do n = 1, nnoderho
         rhon(n) = (n - 1) * drho
!         write(6, 1312)n, rhon(n)
      end do




      rplasm = rt + aplasm
      rlim   = rt + alim




!------------------------------
!    Interpolate to AORSA grid:
!------------------------------

      call aorsa_grid(nmodesx, nmodesy, capr, y, nxmx, nymx, &
          psisep, psimag, bx, by, bz, bxn, byn, bzn, bmod, &
          psi_pol2d, rho_pol2d, rg, zg, psig, psirg, psizg, psirzg, &
          psis, fs, fs1, nxeqdmax, nyeqdmax, nxeqd, nyeqd, ma, psio, &
          qs, qs1, qsafety, r0, b0, psirr, psizz, psirz, &
          rho_tors, rho_tor2d, rmaxis, zmaxis)


      if (myid .eq. 0) then
         write(6, *) &
       "   i       R(x)        x          bx           by           bz"
         write(15,*) &
       "   i       R(x)        x          bx           by           bz"
      end if

      j = jequat
      do i = 1, nmodesx
         if (myid .eq. 0) then
            write(6, 2163)i, capr(i), x(i), bx(i, j), by(i,j), bz(i,j)
            write(15,2163)i, capr(i), x(i), bx(i, j), by(i,j), bz(i,j)
         endif
      end do


         rho = 0.0
!        ----------------------------------------------------
!        Default:  if n_prof_flux equals 0, use poloidal flux
!        ----------------------------------------------------

            do i = 1, nmodesx
               do j = 1, nmodesy
                rho(i,j) = rho_pol2d(i,j)
                psi(i,j) = psi_pol2d(i,j)
                  psi_dim(i,j) = psi(i,j) * psio
               end do
            end do


!        --------------------------------------------------------------
!        Alternate: if n_prof_flux does not equal 0, use toroidal flux
!        Note:  Here we use toroidal flux  inside rho_pol = 1.0
!                       and poloidal flux outside rho_pol = 1.0!!
!        --------------------------------------------------------------
         if(n_prof_flux .ne. 0)then
            do i = 1, nmodesx
               do j = 1, nmodesy
                psi_tor2d(i,j) = rho_tor2d(i,j)**2

              if(rho(i,j) .lt. 1.0)then
                   rho(i,j) = rho_tor2d(i,j)
                   psi(i,j) = psi_tor2d(i,j)
                   psi_dim(i,j) = psi(i,j) * psi_tor_max
                     end if

               end do
            end do
         end if

      if (myid .eq. 0)then

         write(6, *)  "psio = ", psio
       write(15, *) "psio = ", psio
       write(6, *)  "psi_tor_max = ", psi_tor_max
       write(15, *) "psi_tor_max = ", psi_tor_max

         do i = 1, nmodesx
            write(6,  1312)i, capr(i), rho(i,16)
            write(15, 1312)i, capr(i), rho(i,16)
         end do
      end if


      rholim = .99

!      write (6, *)
!      write (6, *) "r0 = ", r0, "m"
!      write (6, *) "b0 = ", b0, "Tesla"
!      write (6, *) "psio = ", psio, "Webers/rad"
!      write (6, *) "psimag = ", psimag, "Webers/rad"
!      write (6, *) "psisep = ", psisep, "Webers/rad"
!      write (6, *) "psi_tor_max = ", psi_tor_max, "Webers/rad"

!      write (115, *)
!      write (115, *) "r0 = ", r0, "m"
!      write (115, *) "b0 = ", b0, "Tesla"
!      write (115, *) "psio = ", psio, "Webers/rad"
!      write (115, *) "psimag = ", psimag, "Webers/rad"
!      write (115, *) "psisep = ", psisep, "Webers/rad"
!      write (115, *) "psi_tor_max = ", psi_tor_max, "Webers/rad"

      do i = 1, nmodesx
         do j = 1, nmodesy
            btau(i,j) = sqrt(bxn(i,j)**2 + byn(i,j)**2)
          bpol(i,j) = btau(i,j) * bmod(i,j)
            bzeta(i,j) = bzn(i,j)
         end do
      end do


!     -------------------------------------
!     Calculate capr * bpol in the midplane
!     -------------------------------------
      do i = 1, nmodesx
         do j = 1, nmodesy
          capr_bpol(i,j) = capr(i) * bpol(i,j)

       end do
      end do

      do i = 1, nmodesx
         do j = 1, nmodesy
            call midplane(i, j, capr_bpol, capr_bpol_mid2(i,j), &
                rho, nxmx, nymx, nmodesx, nmodesy, capr, rt, 0.0, jmid)
              end do
      end do


      call polavg(capr_bpol_mid2, capr_bpol_mid, rho, nxmx, nymx, &
         nrhomax, &
         nmodesx, nmodesy, nnoderho, drho, dx, dy, capr, rt, dvol, fvol)


      if (myid .eq. 0)then

         write(15, *)"rt = ", rt
       write(15, *)"b0 = ", b0
       write(15, *)"dx = ", dx
       write(15, *)"dy = ", dy
       write(15, *)"drho = ", drho

         write(15, *)
         write(15, *) "     i    capr  rhoij  capr_bpol  capr_bpol_mid2"
         write(15, *)

         write(6, *)
         write(6, *)  "     i    capr  rhoij  capr_bpol  capr_bpol_mid2"
         write(6, *)

         do i = 1, nmodesx
            write(6,  1312)i, capr(i), rho(i, jequat), &
                        capr_bpol(i,  jequat), capr_bpol_mid2(i, jequat)
            write(15, 1312)i, capr(i), rho(i, jequat), &
                        capr_bpol(i,  jequat), capr_bpol_mid2(i, jequat)
         end do

         write(15, *)
         write(15, *) "     n   capr_bpol_mid"

         write(6, *)
         write(6, *)  "     n   capr_bpol_mid"

         do n = 1, nnoderho
            write(6,  1312)n, capr_bpol_mid(n)
            write(15, 1312)n, capr_bpol_mid(n)
         end do

      end if


!     -----------------------
!     Calculate bmod_mid(i,j)
!     -----------------------
      do i = 1, nmodesx
         do j = 1, nmodesy
            call midplane(i, j, bmod, bmod_mid(i,j), rho, &
                      nxmx, nymx, nmodesx, nmodesy, capr, rt, b0, jmid)
         end do
      end do

      call polavg(bmod_mid, bmod_midavg, rho, nxmx, nymx, &
         nrhomax, &
         nmodesx, nmodesy, nnoderho, drho, dx, dy, capr, rt, dvol, fvol)


!      if (myid .eq. 0)then

!         write(15, *)
!         write(15, *) "     n        bmod_midavg"

!         write(6, *)
!         write(6, *)  "     n        bmod_midavg"


!         do n = 1, nnoderho
!            write(6,  1312)n, bmod_midavg(n)
!            write(15, 1312)n, bmod_midavg(n)
!         end do

!      end if



      do i = 1, nmodesx
         do j = 1, nmodesy
            bratio(i,j) = bmod_mid(i,j) / bmod(i,j)
!            if(bratio(i,j) .gt. 1.0)
!            if(bratio(i,j) .lt. 0.0)
!     .         write(6, *)i, j, bratio(i,j),rho(i,j)
         end do
      end do



!      write(115, *)
!      write(115, *) "      n  capr_bpol_mid   bmod_mid"

!      write(6, *)
!      write(6, *)  "      n  capr_bpol_mid   bmod_mid"


!      do n = 1, nnoderho
!         write(6,  1312)n, capr_bpol_mid(n), bmod_midavg(n)
!         write(115, 1312)n, capr_bpol_mid(n), bmod_midavg(n)
!      end do


!      write(115, *)
!      write(115, *) "bmod_mid ="




!      write(6, *)
!      write(115, *)

!      do i = 1, nmodesx
!         do j = 1, nmodesy
!            if(j .eq. jequat) then
!               write(6,  1312)i, x(i), bmod(i, j), bmod_mid(i, j)
!               write(115, 1312)i, x(i), bmod(i, j), bmod_mid(i, j)
!            end if
!         end do
!      end do

      bxn_eq = bxn
      byn_eq = byn
      bzn_eq = bzn
      bmod_eq = bmod



!      if(myid .eq. 0) then

!         write(40, 309) nmodesx, nmodesy
!         write(40, 310) rwleft, rwright, ytop, ybottom
!         write(40, 310) rmaxis, zmaxis, b0, psio, psimag, psi_tor_max
!         write(40, 310) ((bxn(i,j), i = 1, nmodesx), j = 1, nmodesy)
!         write(40, 310) ((byn(i,j), i = 1, nmodesx), j = 1, nmodesy)
!         write(40, 310) ((bzn(i,j), i = 1, nmodesx), j = 1, nmodesy)
!         write(40, 310) ((bmod(i,j),i = 1, nmodesx), j = 1, nmodesy)
!         write(40, 310) ((psi(i,j), i = 1, nmodesx), j = 1, nmodesy)
!         write(40, 310) ((rho(i,j), i = 1, nmodesx), j = 1, nmodesy)
!         write(40, 310) ((qsafety(i,j), i = 1, nmodesx), j = 1, nmodesy)
!         write(40, 310) ((bmod_mid(i, j), i = 1, nmodesx), j = 1, nmodesy)
!         write(40, 310) ((capr_bpol_mid2(i, j), i = 1,nmodesx),j = 1,nmodesy)
!         write(40, 310) (capr_bpol_mid(n), n = 1, nnoderho)
!         write(40, 310) ((rho_tor2d(i, j), i = 1,nmodesx),j = 1,nmodesy)

!      end if


      do i = 1, nmodesx
         do j = 1, nmodesy
            call deriv_r(bxn, nxmx, nymx, i, j, nmodesx, nmodesy, capr, &
               dbxdx(i,j), dxxbxn(i,j))
            call deriv_r(byn, nxmx, nymx, i, j, nmodesx, nmodesy, capr, &
               dbydx(i,j), dxxbyn(i,j))
            call deriv_r(bzn, nxmx, nymx, i, j, nmodesx, nmodesy, capr, &
               dbzdx(i,j), dxxbzn(i,j))


            call deriv_z(bxn, nxmx, nymx, i, j, nmodesx, nmodesy, y, &
               dbxdy(i,j), dyybxn(i,j))
            call deriv_z(byn, nxmx, nymx, i, j, nmodesx, nmodesy, y, &
               dbydy(i,j), dyybyn(i,j) )
            call deriv_z(bzn, nxmx, nymx, i, j, nmodesx, nmodesy, y, &
               dbzdy(i,j), dyybzn(i,j) )


            call deriv_rz(bxn, nxmx, nymx, i, j, nmodesx, nmodesy, &
               capr, y, dxybxn(i,j))
            call deriv_rz(byn, nxmx, nymx, i, j, nmodesx, nmodesy, &
               capr, y, dxybyn(i,j))
            call deriv_rz(bzn, nxmx, nymx, i, j, nmodesx, nmodesy, &
               capr, y, dxybzn(i,j))

            call deriv_r(bmod, nxmx, nymx, i, j, nmodesx, nmodesy, capr, &
               dbdx(i,j), dxxmodb(i,j))
            call deriv_z(bmod, nxmx, nymx, i, j, nmodesx, nmodesy, y, &
               dbdy(i,j), dyymodb(i,j) )
            call deriv_rz(bmod, nxmx, nymx, i, j, nmodesx, nmodesy, &
               capr, y, dxymodb(i,j))


            gradprlb(i,j) = bxn(i,j) * dbdx(i,j) + byn(i,j) * dbdy(i,j)

         end do
      end do


!      --------------------------------------------------------
!     Set spline parameters and calculate spline coefficients:
!      sigma = 0.0 for tensor product cubic splines
!      sigma = 50 for bi-linear interpolation
!      documentation recommend sigma=1.0 as standard value
!      --------------------------------------------------------
       sigma = 1.0
      islpsw = 255
      islpsw1 = 3

      call surf1 (nmodesx, nmodesy, xprime, yprime, bxn, nxmx, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zbxn, temp, &
                  sigma, ierr)
      call surf1 (nmodesx, nmodesy, xprime, yprime, byn, nxmx, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zbyn, temp, &
                  sigma, ierr)
      call surf1 (nmodesx, nmodesy, xprime, yprime, bzn, nxmx, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zbzn, temp, &
                  sigma, ierr)
      call surf1 (nmodesx, nmodesy, xprime, yprime, bmod, nxmx, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zbmod, temp, &
                  sigma, ierr)

      call surf1 (nmodesx, nmodesy, xprime, yprime, bratio, nxmx, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zbratio, temp, &
                  sigma, ierr)

      call surf1 (nmodesx, nmodesy, xprime, yprime, psi, nxmx, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zpsi, temp, &
                  sigma, ierr)



      n_theta_check = 75


    i0Loop: &
    do i = i0, nmodesx - 1
    
        j0Loop: &
        do j = j0, j0
        
            capr_x0 = capr(i) + dx / 2.0
            capz_x0 = y(j) + dy / 2.0
            
            x_extint = capr_x0 - rt
            y_extint = capz_x0
            
            xprimex0 = x_extint - xwleft
            yprimex0 = y_extint - ybottom
            
            psix_prev = psix
            
            psix =surf2(xprimex0, yprimex0, nmodesx, nmodesy, &
               xprime, yprime, &
               psi, nxmx, zpsi, sigma)
            
            if(psix .gt. psilim_ .and. psix_prev .le. psilim_)i_max =i-1
        
            psiLimIf: &
            if(psix .le. psilim_)then
            
                i_psi = 1
        
                vPrlSgnLoop: &
                do i_sgn_vprl = 1, 2
                
                    if(i_sgn_vprl .eq. 1) sgn_vprl = -1.0
                    if(i_sgn_vprl .eq. 2) sgn_vprl =  1.0
                    
                    !---------------------
                    !Set extint parameters
                    !---------------------
                    
                    h0 = 1.0e-04
                    nmax = 2
                    mmax = 4
                    eps = 1.0e-06
                    
                    do i_err = 1, nmax
                       s_err(i_err)=.1
                    enddo
                    
                    !-------------------------------------------
                    !Set initial conditions for field line trace
                    !-------------------------------------------
                    
                    phi = 0.0
                    ncell = 0
                    
                    y_phi(1) = xprimex0
                    y_phi(2) = yprimex0
                    
                    icell = int(xprimex0 / dx) + 1
                    jcell = int(yprimex0 / dy) + 1
                    
                    length = 0.0
                    dtau_tot_sum = 0.0
                    dldb_tot_sum = 0.0
                    
                    call f(phi, y_phi, dy_phi)
                    modb_init = modb
                    
                    dTau_tot    = 0.0
                    sinTh2_init = sin ( theta_ )**2
                    
                    !do n_theta = 1, n_theta_(i_psi)
                    !   write(*,*) 'loop index: ', n_theta
                    !   dtau_tot(n_theta) = 0.0
                    !   sinth2_init(n_theta, i_psi)=sin(theta_(n_theta,i_psi))**2
                    !end do
                    
                    !-------------------------------------
                    !Do norb_dim phi steps of field line trace
                    !-------------------------------------
                    
                    i_stop = 0
                    i_box  = 1
                    
                    n_phi_loop: &
                    do n_phi = 1, norb_dim
                    
                        fcount = 0
                        xprime_prev = y_phi(1)
                        yprime_prev = y_phi(2)
                        phi_prev    = phi
                        length_prev = length
                        dxdphi_prev = dxdphi
                        dydphi_prev = dydphi
                        icell_prev = icell
                        jcell_prev = jcell
                        
                        if(ncell .eq. 0 .and. n_phi .eq. 1)nphi_enter = n_phi
                        if(ncell .eq. 0 .and. n_phi .ne. 1)nphi_enter = n_phi - 1
                        
                        call extint(nmax, phi, y_phi, f, h0, mmax, error)
                        
                        ncell = ncell + 1
                        xprimex = y_phi(1)
                        yprimex = y_phi(2)
                        icell = int(xprimex / dx) + 1
                        jcell = int(yprimex / dy) + 1
                        delta_x = xprimex - xprime_prev
                        delta_y = yprimex - yprime_prev
                        delta_phi = phi - phi_prev
                        delta_z = caprx * delta_phi
                        delta_l = sqrt(delta_x**2 + delta_y**2 + delta_z**2)
                        length = length + delta_l
                        x_extint = xprimex + xwleft
                        y_extint = yprimex + ybottom
                        
                        !----------------------------------------------
                        !Save arrays of phi, R, Z, Bmod and l = length
                        !----------------------------------------------
                        
                        phin_x(n_phi) = phi
                        capr_x(n_phi) = x_extint + rt
                        capz_x(n_phi) = y_extint
                        modb_x(n_phi) = modb
                        dlen_x(n_phi) = delta_l
                        len_x (n_phi) = length
                        
                        !-----------------------
                        !Numerical dtau integral
                        !-----------------------
                        
                        nPhiGT2: &
                        if (n_phi .ge. 2) then
                                
                            dl_bratio(n_phi) = delta_l * bratio_phi
                            argi = 1.0 - modb / modb_init * sinth2_init(n_theta_check, i_psi)
                            dl_vprl(n_phi) = 0.0
                            
                            if(argi .ge. 0.0)then
                                vprl = sqrt(argi)
                                dl_vprl(n_phi) = delta_l / vprl
                            end if
                        
                        endif nPhiGT2
                        
                        h0 = twopi / 360.
                        
                        !------------------------------------------------
                        !Wait until B increases at least once; then set
                        !i_stop = 1, and stop at the next B field maximum
                        !(i.e. B decreases)
                        !-----------------------------------------------
                        
                        nPhiGT2_A: &
                        if(n_phi .ge. 2)then
                        
                            delta_b = (modb_x(n_phi) - modb_x(n_phi -1))
                            if (delta_b .ge. 1.0e-05 .and. i_stop .eq. 0)i_stop = 1
                            if (delta_b .lt. -1.0e-05 .and. i_stop .eq. 1)go to 201
                        
                        endif nPhiGT2_A
                    
                    enddo n_phi_loop       
                    
                    !-----------------------
                    !End of field line trace
                    !-----------------------
                    
                    201 continue
                    
                    !DLG: 
                    if ( n_phi > norb_dim ) n_phi = norb_dim
                    
                    nphi_exit = n_phi
                    
                    !-----------------------
                    !Numerical dtau integral:
                    !-----------------------
                    
                    dtau_sum = 0.0
                    
                    do nphii = nphi_enter + 1, nphi_exit - 1
                       dtau_sum = dtau_sum + dl_vprl(nphii)
                    enddo
                    
                    dtau_sum = dtau_sum + 0.5 * dl_vprl(nphi_enter)
                    dtau_sum = dtau_sum + 0.5 * dl_vprl(nphi_exit)
                    
                    
                    !do nphii = nphi_enter, nphi_exit
                    !    write(6, 1312)nphii, dl_vprl(nphii)
                    !enddo
                    
                    
                    dtau_tot_sum = dtau_tot_sum + dtau_sum
                    dldb_tot_sum = 0.0
                    
                    do nphii = 2, n_phi - 1
                        dldb_tot_sum = dldb_tot_sum + dl_bratio(nphii)
                    end do
                    
                    dldb_tot_sum = dldb_tot_sum + 0.5 * dl_bratio(1)
                    dldb_tot_sum = dldb_tot_sum + 0.5 * dl_bratio(nphi)
                    n_phi_max = n_phi - 1
                    
                    
                    !do n_theta = 1, n_theta_(i_psi)
                    
                    if (i_sgn_vprl .eq. 1) then
                        !dtau_tot1(n_theta) = dtau_tot(n_theta)
                        !dtau_first1(n_theta) = dtau_first(n_theta)
                        dtau_tot1 = dtau_tot
                        dtau_first1 = dtau_first
                    end if
                    
                    if (i_sgn_vprl .eq. 2) then
                        !dtau_tot2(n_theta) = dtau_tot(n_theta)
                        !dtau_first2(n_theta) = dtau_first(n_theta)
                        dtau_tot2 = dtau_tot
                        dtau_first2 = dtau_first
                    end if
                    
                    !end do
                    
                    if(i_sgn_vprl .eq. 1)dldb_tot1 = dldb_tot_sum
                    if(i_sgn_vprl .eq. 2)dldb_tot2 = dldb_tot_sum
                    
                enddo vPrlSgnLoop
        
                dldb_tot12(i,j) = dldb_tot1 + dldb_tot2
        
                i_sav = i
                j_sav = j
        
            endif psiLimIF 
        
        enddo j0Loop
    enddo i0Loop


      nrho = i_max - i0 + 1

      rho_ij = rho(1:nmodesx, 1:nmodesy)
      allocate (rho_in(nrho), profile_in(nrho), &
                                         profile_out(nmodesx, nmodesy))

      profile_in = dldb_tot12(i0:i_max, j0)
      rho_in =            rho(i0:i_max, j0)

      if(myid .eq. 0)print*, 'rho_in  ',rho_in
      if(myid .eq. 0)print*, 'profile_in  ',profile_in

!     -----------------------------
!     deposit dldb on 2D flux grid:
!     -----------------------------
      call flux_to_rz(nmodesx, nmodesy, profile_in, &
         profile_out, rho_in, nrho, rho_ij)

      dldb_tot12(1:nmodesx, 1:nmodesy) = profile_out

      call polavg(dldb_tot12, dldbavg, rho, nxmx, nymx, nrhomax, &
         nmodesx, nmodesy, nnoderho, drho, dx, dy, capr, rt, dvol, fvol)

      call volume_xy(rho, nxmx, nymx, nrhomax, &
         nmodesx, nmodesy, nnoderho, drho, dx, dy, capr, rt, dvol_xy)



9318  format(a128)

 1213 format(2i10, 1p5e12.4, 3i5)
 1214 format(1p4e12.4, 3i5)


      if(myid .eq. 0)then

      write(138, 309) nmodesx, nmodesy, nxeqd
      write(138, 310) rholim, rhowall
      write(138, 310) (x(i), i = 1, nmodesx)
      write(138, 310) (y(j), j = 1, nmodesy)
      write(138, 310) (capr(i), i = 1, nmodesx)
      write(138, 310) ((theta(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((bmod(i, j),i = 1, nmodesx),j = 1,nmodesy)
      write(138, 310) ((rho(i, j), i = 1, nmodesx),j = 1,nmodesy)
      write(138, 310) ((psi(i, j), i = 1, nmodesx),j = 1, nmodesy)
      write(138, 310) ((qsafety(i,j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((btau(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((bzeta(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((dbxdx(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dbydx(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dbzdx(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((dbxdy(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dbydy(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dbzdy(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((dbdx(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dbdy(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((psizz(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((psirr(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((psirz(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) (psigrid(i), i = 1, nxeqd)
      write(138, 310) (rhoeqdsk(i), i = 1, nxeqd)
      write(138, 310) (qpsi(i), i = 1, nxeqd)

      write(138, 310) ((dxxbxn(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dxxbyn(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dxxbzn(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((dxybxn(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dxybyn(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dxybzn(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((dyybxn(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dyybyn(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dyybzn(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((dxxmodb(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dxymodb(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((dyymodb(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((gradprlb(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 310) ((bmod_mid(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((capr_bpol_mid2(i, j), i = 1,nmodesx),j= 1,nmodesy)

      write(138, 309) nnoderho
      write(138, 310) (rhon(n), n = 1, nnoderho)
      write(138, 310) (capr_bpol_mid(n), n = 1, nnoderho)
      write(138, 310) (bmod_midavg(n), n = 1, nnoderho)

      write(138, 310) ((rho_tor2d(i, j), i = 1, nmodesx), j = 1, nmodesy)

      write(138, 309) n_phi_max
      write(138, 310) (capr_x(n_phi), n_phi = 1, n_phi_max)
      write(138, 310) (capz_x(n_phi), n_phi = 1, n_phi_max)

      write(138, 310) ((dldb_tot12(i, j), i = 1, nmodesx), &
                                         j = 1, nmodesy)
      write(138, 310) (dldbavg(n), n = 1, nnoderho)


      write(138, 310) ((bx(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((by(i, j), i = 1, nmodesx), j = 1, nmodesy)
      write(138, 310) ((bz(i, j), i = 1, nmodesx), j = 1, nmodesy)

      close (138)

      end if

!     -----------------------
!     do plotting with pgplot
!     -----------------------

!      if(myid .eq. 0)call eqdsk_plot

!      tmin = (second1(dummy) - t1) / 60.
!      write(6 , 2846) tmin
!      write(115, 2846) tmin

 2846 format('time to do plots =', f9.3, ' min')

!      if(myid .eq. 0) close (115)



  310 format(1p6e12.4)
  309 format(10i10)
 9310 format(1p7e12.4)
  311 format(1p10e12.4)
 9311 format(10i10)
 3117 format(1p11e12.4)
 1312 format(i10, 1p8e12.4)
 1314 format (2i10, 1p8e12.4)
 1414 format (1i10, 1p5e12.4, 1i10)
13149 format (4i10, 1p8e12.4)
 1313 format(10i10)
 1311 format(1p9e12.4)
   10 format(i10,1p4e10.3,i10,1pe10.3)
 1010 format(1f4.0,4f8.3,3f7.3,1f8.3,1f9.3,2f8.3)
 1009 format(3x,21h        frequency  = ,1pe12.4,7h hertz )
 1012 format(3x,21h             omgrf = ,1pe12.4,7h hertz )
 2012 format(3x,51h2*pi*rt/Ly * real part of impedance (resistance) = , &
         1pe12.4,10h ohms     )
 2013 format(3x, &
         55h2*pi*rt/Ly * imaginary part of impedance (reactance) = , &
         1pe12.4,10h ohms     )
 1014 format(3x,21h               xkz = ,1pe12.4,7h m-1   )
 1321 format(3x,21h         vph / vth = ,1pe12.4,7h       )
 1391 format(3x,21h critical shear(0) = ,1pe12.4,7h s-1   )
 1392 format(3x,21h critical shear(a) = ,1pe12.4,7h s-1   )
 1393 format(3x,21h         mu neo(a) = ,1pe12.4,7h s-1   )
 1322 format(3x,21h               vph = ,1pe12.4,7h       )
 1323 format(3x,21h               vth = ,1pe12.4,7h       )
 1714 format(3x,21h               xk0 = ,1pe12.4,7h m-1   )
 1021 format(3x,21h        n parallel = ,1pe12.4,7h       )
 1022 format(3x,21h           rhonorm = ,1pe12.4,7h m     )
 1812 format(3x,21h                rt = ,1pe12.4,7h m     )
 1822 format(3x,21h            aplasm = ,1pe12.4,7h m     )
 1823 format(3x,21h              rant = ,1pe12.4,7h m     )
 1809 format(3x,21h                b0 = ,1pe12.4,7h T     )
 1813 format(3x,21h              xn10 = ,1pe12.4,7h m-3   )
 6813 format(3x,21h              xne0 = ,1pe12.4,7h m-3   )
 1814 format(3x,21h              xn20 = ,1pe12.4,7h m-3   )
 1834 format(3x,21h              xn30 = ,1pe12.4,7h m-3   )
 6834 format(3x,21h              eta1 = ,1pe12.4,7h       )
 6835 format(3x,21h              eta2 = ,1pe12.4,7h       )
 6836 format(3x,21h              eta3 = ,1pe12.4,7h       )
 1815 format(3x,21h               te0 = ,1pe12.4,7h eV    )
 1821 format(3x,21h               ti0 = ,1pe12.4,7h eV    )
 1016 format(3x,21h xnue/omgrf ad hoc = ,1pe12.4,7h       )
 1017 format(3x,21h xnu1/omgrf ad hoc = ,1pe12.4,7h       )
 1018 format(3x,21h xnu2/omgrf ad hoc = ,1pe12.4,7h       )
 1013 format(3x,21h              nphi = ,i12,7h       )
 7013 format(3x,21h           nmodesx = ,i12,7h       / &
             3x,21h           nmodesy = ,i12,7h       )

 7113 format(3x,21h             nwdot = ,i12,7h       )
 7213 format(3x,21h           nnodecx = ,i12,7h       / &
             3x,21h           nnodecy = ,i12,7h       )
 7014 format(3x,21h              lmax = ,i12,7h       )
 7015 format(3x,21h           ibessel = ,i12,7h       )
 7115 format(3x,21h             nzfun = ,i12,7h       )
 7016 format(3x,21h         rhoi1 / L = ,1pe12.4,7h       )
 7017 format(3x,21h             rhoi1 = ,1pe12.4,7h m     )
 7217 format(3x,21h             qavg0 = ,1pe12.4,7h       )
 1020 format(3x,21h            nmodesx = ,i12, 7h       / &
             3x,21h            nmodesy = ,i12, 7h       )

 3013 format(3x,21h                i0 = ,i12,7h       )
30131 format(3x,21h             ileft = ,i12,7h       )
30132 format(3x,21h            iright = ,i12,7h       )
 3014 format(3x,21h xnuii(0)/omgti(0) = ,1pe12.4,7h s-1   )
 3015 format(3x,21h           vthi(0) = ,1pe12.4,7h m/s   )
 3016 format(3x,21h          omgti(0) = ,1pe12.4,7h s-1   )
 3017 format(3x,21h           xnup(0) = ,1pe12.4,7h s-1   )
 3018 format(3x,21h          eps**1.5 = ,1pe12.4,7h       )
71160 format(3x,21h         xnu / omg = ,1pe12.4,7h       )


  162 format(1h1)
  169 format(1h )
  163 format(1h0)
 2162 format(1p8e12.4)
 2163 format(i5, 1p11e12.3)
 2165 format(3i10,1p5e12.3)
 1002 format(2i10,7e10.3)
11313 format(2i10, 1p8e12.4)
 1000 format(1i10,7e10.3)
 2000 format(1i10,1e10.3,1i10,1e10.3)
 1001 format(8e10.3)


!      time=second1(dummy)-time0

!      ttotal = time/60.


  899 format('total cpu time used =',f9.3,4h min)


      return

      end subroutine eqdsk_setup

!
!***************************************************************************
!


!      real function second1_old(dummy)

!      implicit none

!      integer :: v(8)
!      integer mtime, mclock
!      real dummy

!*****Fortran 90 standard for wall clock time
!      call date_and_time(values=v)
!      second1_old=(v(5)*3600)+(v(6)*60)+v(7)+0.001d0*v(8)

!*****FALCON:
!      double precision mpi_wtime
!      external mpi_wtime
!      second1_old = MPI_WTIME()


!*****EAGLE:
!      mtime = mclock()
!      second1_old  = 0.01 * mtime

!      return
!      end

!
!***************************************************************************
!



      subroutine aorsa_grid(nmodesx, nmodesy, capr, capz, nxmx, nymx, &
         psisep, psimag, bx0, by0, bz0, bxn, byn, bzn, bmod, &
         psi, rho, rg, zg, psig, psirg, psizg, psirzg, &
         psis, fs, fs1, nxeqdmax, nyeqdmax, mr, mz, ma, psio, &
         qs, qs1, qsafety, r0, b0, psirr, psizz, psirz, &
         rho_tors, rho_tor2d, rmaxis, zmaxis)

      use fitpack

      implicit none

      integer i, j, nmodesx, nmodesy, mode, nxmx, nymx, mr, mz, ma
      integer ihalf, jequat, ir, iz, ipsi, nxeqdmax, nyeqdmax

      integer islpsw, islpsw1, ierr
      real sigma, slp1, slpn, rmaxis, zmaxis
        real zx1(nyeqdmax), zxm(nyeqdmax), zy1(nxeqdmax), zyn(nxeqdmax)
        real zxy11, zxym1, zxy1n, zxymn
      real zp(nxeqdmax, nyeqdmax, 3)
      real zpr(nxeqdmax, nyeqdmax, 3)
      real zpz(nxeqdmax, nyeqdmax, 3)
        real temp(nxeqdmax + nxeqdmax + nyeqdmax )
      real surf2, curv2

      real capr(nxmx), capz(nymx), r, z, psio, r0, b0, b0_dlg
      real bx0(nxmx, nymx), by0(nxmx, nymx), bz0(nxmx, nymx)
      real bxn(nxmx, nymx), byn(nxmx, nymx), bzn(nxmx, nymx)
      real :: bz0_bak(nxmx, nymx)

      real psi(nxmx, nymx), rho(nxmx, nymx)
      real qsafety(nxmx, nymx)
      real rho_tor2d(nxmx, nymx)
      real psihigh, psilow
      real bmod(nxmx, nymx)
      real ps, psr, psz, psrr, psrz, pszz
      real f_psi, f_psi_psi, f_3psi
      real f, f_a, f_a_a, f_3a, a
      real q, q_a, q_a_a, q_3a
      real bphi, bpsi0, br, bz, psisep, psimag
      real dbrdr, dbrdz, dbzdr, dbzdz, dbphidr, dbphidz
      real dbmoddr, dbmoddz

      real psis(nxeqdmax), fs(nxeqdmax), fs1(nxeqdmax)
      real qs(nxeqdmax), qs1(nxeqdmax)
      real rho_tors(nxeqdmax)
      real rg(nxeqdmax), zg(nyeqdmax), psig(nxeqdmax, nyeqdmax)
      real psirg(nxeqdmax, nyeqdmax), psizg(nxeqdmax, nyeqdmax)
      real psirzg(nxeqdmax, nyeqdmax)

      real ypf(nxeqdmax), ypq(nxeqdmax), temp1(nxeqdmax)
      real yprho(nxeqdmax), rhot

      real psizz(nxmx, nymx), psirr(nxmx, nymx), psirz(nxmx, nymx)



      jequat = nmodesy / 2
      ihalf = nmodesx / 2


!      ----------------------------------
!      sigma = 0.0 for tensor product cubic splines
!      sigma = 50 for bi-linear interpolation
!      documentation recommend sigma=1.0 as standard value
!      ----------------------------------
       sigma = 1.0
      islpsw = 255
      islpsw1 = 3
      call surf1 (mr, mz, rg, zg, psig, nxeqdmax, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zp, temp, &
                  sigma, ierr)

      call surf1 (mr, mz, rg, zg, psirg, nxeqdmax, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zpr, temp, &
                  sigma, ierr)

      call surf1 (mr, mz, rg, zg, psizg, nxeqdmax, &
                  zx1, zxm, zy1, zyn, &
                  zxy11, zxym1, zxy1n, zxymn, &
                  islpsw, zpz, temp, &
                  sigma, ierr)

      call curv1 (ma, psis, fs, slp1, slpn, islpsw1, &
             ypf, temp1, sigma, ierr)

      call curv1 (ma, psis, qs, slp1, slpn, islpsw1, &
             ypq, temp1, sigma, ierr)

      call curv1 (ma, psis, rho_tors, slp1, slpn, islpsw1, &
             yprho, temp1, sigma, ierr)

      do i = 1, nmodesx
         do j = 1, nmodesy
            r = capr(i)
            z = capz(j)



!           calculate fields:


            ps = surf2 (r, z, mr, mz, rg, zg, psig, nxeqdmax, &
                 zp, sigma)

            psr = surf2 (r, z, mr, mz, rg, zg, psirg, nxeqdmax, &
                 zpr, sigma)

            psz = surf2 (r, z, mr, mz, rg, zg, psizg, nxeqdmax, &
                 zpz, sigma)


            a = (ps - psio) / (0.0 - psio)
            psi(i, j) = a
            !DLG
            if(a .gt. .999) a = .999


            f = curv2(a, ma, psis, fs, ypf, sigma)
            q = curv2(a, ma, psis, qs, ypq, sigma)
            rhot = curv2(a, ma, psis, rho_tors, yprho, sigma)


            bphi = f / r
            bpsi0 = 0.0



!           -------------------------------------------------
!           Minus sign because psig(i,j) = psilim - psig(i,j)
!           -------------------------------------------------
            br =  1./r * psz
            bz = -1./r * psr


!           -----------------------------
!           To set poloidal field to zero
!           -----------------------------
!            br = 1.0e-07
!            bz = 1.0e-07


            qsafety(i, j) = q
            rho_tor2d(i,j) = rhot

            rho(i,j) = 0.0
            if(psi(i,j) .gt. 0.0)rho(i, j) = sqrt(psi(i,j))

            bx0(i, j) = br
            by0(i, j) = bz
            bz0(i, j) = bphi

         end do
      end do


      bmod = sqrt(bx0**2 + by0**2 + bz0**2)

      bxn = bx0 / bmod
      byn = by0 / bmod
      bzn = bz0 / bmod

!     --------
!     Find b0:
!     --------
      a = 1.e-04
      f = curv2(a, ma, psis, fs, ypf, sigma)
      b0 = f / r0

      if ( use_dlg_bField ) b0 = b0_dlg


 1312 format(i10, 1p8e12.4)
  310 format(1p6e12.4)

      return
      end subroutine aorsa_grid

!
!***************************************************************************
!
      subroutine readeq_ga(nw, nh, rhoeqdskw, &
         psigridw, agrid, psimag, psilim, &
         rmin, rmax, zmin, zmax, rma, zma, beqd, &
         rmhdgrid, zmhdgrid, psi, nxeqd, nyeqd, fpsiw, &
         psio, ro, zo, qpsiw, eqdsk, psi_tor_max)

      implicit none

      integer nw, nh, ncontrmx, maxlimpt

      parameter (ncontrmx = 2000, maxlimpt = 200)

      character*80 ntitle(5)*8
      character*8 dati, eqdsrce*40

      CHARACTER*128 :: eqdsk

      integer i,j,l,k, nlimtr, ncontr
      integer nxeqd, nyeqd, ipestg, nameqdsk, ieqdsk

      real zcontr(ncontrmx), rcontr(ncontrmx), psio, ro, zo, test
      real  zsep, rsep, sum, dpsii, qval, rhomax
      real ylimiter(maxlimpt), xlimiter(maxlimpt)
      real dpsi, psisep, sdimeqd, redeqd, reqd, ydimeqd

      real zax1, zax2, xax1, xax2, ymideqd, xdimeqd, &
          toteqd, beqd, psimx2, psimx1, zma, rma, psi_tor_max

      real psigrid(nw), rhoeqdsk(nw), psi(nw,nh), qpsi(nw), qpsiw(nw)
      real psigridw(nw), rhoeqdskw(nw), agrid(nw)
      real fpsi(nw), presspsi(nw), ffppsi(nw), pppsi(nw)
      real fpsiw(nw)

      real psilim, psimag

      real dyneqd, dxneqd, rmhdgrid(nw), zmhdgrid(nh)
      real rmin, rmax, zmin, zmax

      call plasma_state_eq(nw, nh, ntitle, nxeqd ,nyeqd, eqdsrce, &
         xdimeqd, ydimeqd, reqd, redeqd, ymideqd, &
         rma, zma, psimag, psilim, beqd, &
         toteqd, psimx1, psimx2, xax1, xax2, &
         zax1, zax2, psisep, rsep, zsep, fpsi, &
         presspsi, ffppsi, pppsi, psi, qpsi, eqdsk)

!      write(6, *) "fpsi(j) = "
!      write(6,8200) (fpsi(j), j=nxeqd, 1, -1)
! 8200 format(5e16.9)


!
! --- done reading eqdsk file
! --- set up the mhdgrid(s)
!
      rmin = redeqd
      rmax = redeqd + xdimeqd

      dxneqd = (rmax - rmin) / (nxeqd - 1)
      do i = 1, nxeqd
         rmhdgrid(i) = rmin + (i - 1) * dxneqd
      end do


      zmin = - ydimeqd / 2.0
      zmax =   ydimeqd / 2.0

      dyneqd = (zmax - zmin) / (nyeqd - 1)
      do j = 1, nyeqd
         zmhdgrid(j) = zmin + (j - 1) * dyneqd
      end do


 1312 format(i10, 1p8e12.4)
  310 format(1p6e12.4)


      do i = 1, nxeqd
         do j = 1, nyeqd
           psi(i,j) = psilim - psi(i,j)
         end do
      end do

      psio = psilim - psimag
      ro = rma
      zo = zma


!
! --- set up the psi grid. note that edge is psigrid(1,ieqdsk)
! --- and mag axis is psigrid(nw,ieqdsk)
!

       dpsi=(psimag - psilim) / (nxeqd - 1)
       psigrid(1) = psilim
       do j = 2, nxeqd-1
           psigrid(j) = psigrid(j-1) + dpsi
!           write(6, 1312)j, psigrid(j)
       end do

       psigrid(nxeqd)=psimag

!-----------------------------------------
! --- Toroidal flux by integrating q:
!-----------------------------------------
! --- form rho from info on eqdsk. use rho*drho=q*dpsi/bt0
! --- which becomes rho=sqrt(2*intg(q*dpsi)/bt0)
! --- psigrid(nw,i) is axis,psigrid(1,i) is edge
! --- due to coarseness of grid there may be some inaccuracy here
!
      rhoeqdsk(nxeqd) = 0.0
      dpsii = psigrid(2) - psigrid(1)
      sum = 0.0
      do j = nxeqd - 1, 1, -1
          qval = 0.5 * (qpsi(j) + qpsi(j+1))
          sum = sum + dpsii * qval
          rhoeqdsk(j) = sqrt(abs(2. * sum / beqd))
      end do
      rhomax = rhoeqdsk(1)
      psi_tor_max = rhomax**2 * beqd / 2.


      do j = 1, nxeqd
          rhoeqdsk(j) = rhoeqdsk(j) / rhomax
      end do

!      write(6, *)
!      write(6, *)"    rhoeqdskw     psigridw       agrid"
!      write(6, *)

      do j = 1, nxeqd
         psigridw(j) =   psigrid(nxeqd + 1 - j)
         rhoeqdskw(j) = rhoeqdsk(nxeqd + 1 - j)
         fpsiw(j) = fpsi(nxeqd + 1 - j)
         qpsiw(j) = qpsi(nxeqd + 1 - j)
         agrid(j) = (psigridw(j) - psimag) / (psilim - psimag)
       test = psio * agrid(j)
         if (j.eq.1) agrid(j) = 0.0
!         write(6,692) rhoeqdskw(j), psigridw(j), agrid(j), test
      end do

  692 format(4(2x,1pe12.4))
  700 format(2i10)


      return
      end subroutine readeq_ga
!
!***************************************************************************
!

      subroutine deriv_r(f, id, jd, i, j, imax, jmax, rg, dfdr, d2fdr2)

      implicit none

      integer id, jd, i, j, imax, jmax
      real f(id, jd), rg(id), dfdr, d2fdr2

      if(i .ne. 1 .and. i .ne. imax)then
         dfdr = (f(i+1, j) - f(i-1, j)) / (rg(i+1) - rg(i-1))
         d2fdr2 = (f(i+1, j) - 2.0 * f(i,j) + f(i-1, j)) / &
                    (rg(i+1) - rg(i))**2
      end if

      if(i .eq. 1)then
         dfdr = (f(i+1, j) - f(i, j)) / (rg(i+1) - rg(i))
         d2fdr2 = (f(i+2, j) - 2.0 * f(i+1,j) + f(i, j)) / &
                    (rg(i+1) - rg(i))**2
      end if

      if(i .eq. imax)then
         dfdr = (f(i, j) - f(i-1, j)) /  (rg(i) - rg(i-1))
         d2fdr2 = (f(i, j) - 2.0 * f(i-1,j) + f(i-2, j)) / &
                    (rg(i) - rg(i-1))**2
      end if

      return
      end subroutine deriv_r

!
!***************************************************************************
!
      subroutine deriv_z(f, id, jd, i, j, imax, jmax, zg, dfdz, d2fdz2)

      implicit none

      integer id, jd, i, j, imax, jmax
      real f(id, jd), zg(jd), dfdz, d2fdz2

      if(j .ne. 1 .and. j .ne. jmax)then
         dfdz = (f(i, j+1) - f(i, j-1)) / (zg(j+1) - zg(j-1))
         d2fdz2 = (f(i, j+1) - 2.0 * f(i,j) + f(i, j-1)) / &
            (zg(j+1) - zg(j))**2
      end if

      if(j .eq. 1)then
         dfdz = (f(i, j+1) - f(i, j)) / (zg(j+1) - zg(j))
         d2fdz2 = (f(i, j+2) - 2.0 * f(i,j+1) + f(i, j)) / &
            (zg(j+1) - zg(j))**2
      end if

      if(j .eq. jmax)then
         dfdz = (f(i, j) - f(i, j-1)) /  (zg(j) - zg(j-1))
         d2fdz2 = (f(i, j) - 2.0 * f(i,j-1) + f(i, j-2)) / &
            (zg(j) - zg(j-1))**2
      end if

      return
      end subroutine deriv_z

!
!***************************************************************************
!
      subroutine deriv_rz(f, id, jd, i, j, imax, jmax, rg, zg, d2fdrz)

      implicit none

      integer id, jd, i, j, imax, jmax
      real f(id, jd), rg(id), zg(jd), d2fdrz

      d2fdrz = 0.0

      if(i .ne. 1 .and. i .ne. imax  .and. &
         j .ne. 1 .and. j .ne. jmax)then

         d2fdrz = (f(i+1,j+1) - f(i+1,j-1) - f(i-1,j+1) + f(i-1,j-1)) &
            / ((zg(j+1) - zg(j-1)) * (rg(i+1) - rg(i-1)))

      end if


      return
      end subroutine deriv_rz

!
!***************************************************************************
!
      subroutine deriv_rzOld(f, id, jd, i, j, imax, jmax, rg, zg, dfdrz)

      implicit none

      integer id, jd, i, j, imax, jmax
      real f(id, jd), rg(id), zg(jd), dfdrz

      if(i .ne. 1 .and. i .ne. imax .and. j .ne. 1 .and. j .ne. jmax) &
         dfdrz = (f(i+1, j+1) - f(i+1, j-1) - f(i-1, j+1) + f(i-1, j-1)) &
               / ((rg(i+1) - rg(i-1)) * (zg(j+1) - zg(j-1)))


      if(i .eq. 1 .and. j .ne. 1 .and. j .ne. jmax) &
         dfdrz = (f(i+1, j+1) - f(i+1, j-1) - f(i, j+1) + f(i, j-1)) &
               / ((rg(i+1) - rg(i)) * (zg(j+1) - zg(j-1)))
      if(i .eq. imax .and. j .ne. 1 .and. j .ne. jmax) &
         dfdrz = (f(i, j+1) - f(i, j-1) - f(i-1, j+1) + f(i-1, j-1)) &
               / ((rg(i) - rg(i-1)) * (zg(j+1) - zg(j-1)))
      if(j .eq. 1 .and. i .ne. 1 .and. i .ne. imax ) &
         dfdrz = (f(i+1, j+1) - f(i+1, j) - f(i-1, j+1) + f(i-1, j)) &
               / ((rg(i+1) - rg(i-1)) * (zg(j+1) - zg(j)))
      if(j .eq. jmax .and. i .ne. 1 .and. i .ne. imax ) &
         dfdrz = (f(i+1, j) - f(i+1, j-1) - f(i-1, j) + f(i-1, j-1)) &
               / ((rg(i+1) - rg(i-1)) * (zg(j) - zg(j-1)))

      if(i .eq. 1 .and. j .eq. 1) &
         dfdrz = (f(i+1, j+1) - f(i+1, j) - f(i, j+1) + f(i, j)) &
               / ((rg(i+1) - rg(i)) * (zg(j+1) - zg(j)))

      if(i .eq. 1 .and. j .eq. jmax) &
         dfdrz = (f(i+1, j) - f(i+1, j-1) - f(i, j) + f(i, j-1)) &
               / ((rg(i+1) - rg(i)) * (zg(j) - zg(j-1)))

      if(i .eq. imax .and. j .eq. 1) &
         dfdrz = (f(i, j+1) - f(i, j) - f(i-1, j+1) + f(i-1, j)) &
               / ((rg(i) - rg(i-1)) * (zg(j+1) - zg(j)))

      if(i .eq. imax .and. j .eq. jmax) &
         dfdrz = (f(i, j) - f(i, j-1) - f(i-1, j) + f(i-1, j-1)) &
               / ((rg(i) - rg(i-1)) * (zg(j) - zg(j-1)))


      return
      end subroutine deriv_rzOld

!
!***************************************************************************
!

      subroutine deriv_x_eq(f, x, jd, j, jmax, dfdx)

      implicit none

      integer jd, j, jmax
      real f(jd), x(jd), dfdx

      if(j .ne. 1 .and. j .ne. jmax) &
         dfdx = (f(j+1) - f(j-1)) / (x(j+1) - x(j-1))
      if(j .eq. 1) &
         dfdx = (f(j+1) - f(j)) / (x(j+1) - x(j))
      if(j .eq. jmax) &
         dfdx = (f(j) - f(j-1)) /  (x(j) - x(j-1))

      return
      end subroutine deriv_x_eq

!
!***************************************************************************
!
      subroutine smooth(ntimes, f, id, jd, imax, jmax, fsmooth)

      implicit none

      integer id, jd, i, j, imax, jmax, ntimes, n
      real f(id, jd), fsmooth(id, jd)


      do n = 1, ntimes


         do i = 2, imax - 1
            do j = 2, jmax - 1
               fsmooth(i,j) = 0.5 * f(i,j) &
                  + 0.25 * (f(i+1,j) + f(i-1,j) + f(i,j-1) +f(i,j+1))
            end do
         end do

         do i = 2, imax - 1
            do j = 2, jmax - 1
               f(i,j) = fsmooth(i,j)
            end do
         end do


      end do

      return
      end subroutine smooth

!
!***************************************************************************
!

      subroutine volume_xy(rho, nxmx, nymx, nrhodim, &
         nmodesx, nmodesy, nnoderho, drho, dx, dy, capr, r0, vol)

      implicit none

      integer nxmx, nymx, nrhodim, nmodesx, nmodesy, nnoderho
      integer n, i, j

      real rho(nxmx, nymx), r0, drho, dx, dy, vol(nrhodim), &
         capr(nxmx), pi, twopi

      pi = 3.14159
      twopi = 2.0 * pi

      do n = 1, nnoderho
          vol(n) = 0.0
      end do

      do i = 1, nmodesx
         do j = 1, nmodesy
            n = int(rho(i,j) / drho) + 1
            if(n .le. nnoderho)then
               vol(n) =  vol(n) + dx * dy * twopi * capr(i)
            end if
         end do
      end do


  100 format (1i10, 1p8e12.4)
  102 format (2i10)
      return
      end subroutine volume_xy
!
!***************************************************************************
!

      subroutine plasma_state_eq(nw, nh, ntitle, nxeqd ,nyeqd, eqdsrce, &
         xdimeqd, ydimeqd, reqd, redeqd, ymideqd, &
         rma, zma, psimag, psilim, beqd, &
         toteqd, psimx1, psimx2, xax1, xax2, &
         zax1, zax2, psisep, rsep, zsep, fpsi, &
         presspsi, ffppsi, pppsi, psi, qpsi, eqdsk)

      implicit none

      integer nw, nh, ncontrmx, maxlimpt
      integer i, j, l, k, nlimtr, ncontr
      integer nxeqd, nyeqd, ipestg, nameqdsk, ieqdsk

      character*80 ntitle(5)*8
      character*8 dati, eqdsrce*40
      CHARACTER*128 :: eqdsk

      real fpsi(nw), presspsi(nw), ffppsi(nw), pppsi(nw)
      real psigrid(nw), rhoeqdsk(nw), psi(nw, nh), qpsi(nw), qpsiw(nw)
      real zax1, zax2, xax1, xax2, ymideqd, xdimeqd, &
           toteqd, beqd, psimx2, psimx1, zma, rma
      real zsep, rsep, sum, dpsii, qval, rhomax
      real psilim, psimag
      real dpsi, psisep, sdimeqd, redeqd, reqd, ydimeqd


!     -------------------
!     read the eqdsk file
!     -------------------

      open (unit=5, status = 'OLD', file =eqdsk, form ='formatted')
      rewind (5)

      read (5, 8190) (ntitle(j),j=1,5), dati, ipestg, &
                                            nxeqd ,nyeqd, eqdsrce
      read(5,8200) xdimeqd, ydimeqd, reqd, redeqd, ymideqd
      read(5,8200) rma, zma, psimag, psilim, beqd
      read(5,8200) toteqd, psimx1, psimx2, xax1, xax2
      read(5,8200) zax1, zax2, psisep, rsep, zsep
      read(5,8200) (fpsi(j), j = nxeqd, 1, -1)
      read(5,8200) (presspsi(j), j = nxeqd, 1, -1)
      read(5,8200) (ffppsi(j), j = nxeqd, 1, -1)
      read(5,8200) (pppsi(j), j = nxeqd, 1, -1)
      read(5,8200) ((psi(l,j), l = 1,nxeqd),j = 1, nyeqd)
      read(5,8200) (qpsi(j), j = nxeqd, 1, -1)
      close (5)


   10 format (5i10)
 8190 format(6a8,3i4,t73,a)
 8200 format(5e16.9)
 8210 format(2i5)
 8235 format(4(2x,i5))

      return
      end subroutine plasma_state_eq 

!
!***************************************************************************
!


end module eqdsk_setup_mod
