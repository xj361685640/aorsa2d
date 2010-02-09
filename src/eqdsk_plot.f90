module eqdsk_plot_mod

contains

      subroutine eqdsk_plot
      use parameters
      use plot_aorsa2dps

      implicit none


      character*32 title
      character*32 titll
      character*32 titlr
      character*32 titx
      character*32 tity
      character*32 titz
      character*32 titlb

      real logmax
      integer nlevmax
      integer ibackground, nkx1, nkx2, nky1, nky2, n, m, &
         nkpltdim, mkpltdim, nkxplt, nkyplt

      integer  ncolln10, ncolln9, nwheat, ngrey, naqua, &
         npink, nblueviolet, ncyan, nbrown, nblue, nyellow, ngreen, &
         nblack, nred, nturquoise, ncolln6, ncolln7, ncolln4, ncolln5, &
         ncolln8, nwhite, ncolbox, nmagenta, nsalmon, ncolln2, &
         ncolln3, ncolbrd, ncolln1, ncollin, ncollab, ncolion, &
         ncolelec, norange

      integer nnoderho, iflag, nxeqdmax, nyeqdmax, &
          nnoderho_half, nnoderho2_half

      integer pgopen, pgbeg, ier
!      integer nmodesmax, mmodesmax

      parameter (nlevmax = 101)

!      parameter (nmodesmax = 450)
!      parameter (mmodesmax = 450)

      !parameter (nxmx = nmodesmax)
      !parameter (nymx = mmodesmax)

      !parameter (nrhomax = nxmx)

      !parameter (nkdim1 = - nxmx / 2)
      !parameter (nkdim2 =   nxmx / 2)

      !parameter (mkdim1 = - nxmx / 2)
      !parameter (mkdim2 =   nxmx / 2)

      parameter (nkpltdim = 2 * nkdim2)
      parameter (mkpltdim = 2 * mkdim2)

      parameter (nxeqdmax = 550, nyeqdmax = 550)

      real capr_x(6000), capz_x(6000)
      integer n_phi, n_phi_max
      real rho_tor2d(nxmx, nymx)

      real rhoeqdsk(nxeqdmax), psigrid(nxeqdmax), agrid(nxeqdmax), &
         fpsi(nxeqdmax), dfpsida(nxeqdmax), &
         qpsi(nxeqdmax), dqpsida(nxeqdmax)

      real dxxbxn(nxmx, nymx), dxxbyn(nxmx, nymx), dxxbzn(nxmx, nymx), &
           dxybxn(nxmx, nymx), dxybyn(nxmx, nymx), dxybzn(nxmx, nymx), &
           dyybxn(nxmx, nymx), dyybyn(nxmx, nymx), dyybzn(nxmx, nymx), &
           dxxmodb(nxmx, nymx), dxymodb(nxmx, nymx), dyymodb(nxmx, nymx)

      real bx(nxmx, nymx), by(nxmx, nymx), bz(nxmx, nymx)

      real dldb_tot12(nxmx, nymx)


      real xkxsav(nkpltdim), xkysav(mkpltdim), pscale
!      real wdoti1avg(nrhomax), wdoti2avg(nrhomax), xnavg(nrhomax)

      real rhon(nrhomax), vyi1avg(nrhomax),  vyi2avg(nrhomax), &
           rhon_half(nrhomax)
      real vyavg(nrhomax), dvydrho(nrhomax), wdoteavg(nrhomax)

      real capr_bpol_midavg(nrhomax), bmod_midavg(nrhomax), &
           dldbavg(nrhomax)

!      real redotjeavg(nrhomax), redotj1avg(nrhomax),
!     .     redotj2avg(nrhomax), redotj3avg(nrhomax),
!     .     redotjtavg(nrhomax)

      common/colcom/nblack,nred,nyellow,ngreen,naqua,npink, &
         nwheat,ngrey,nbrown,nblue,nblueviolet,ncyan, &
         nturquoise,nmagenta,nsalmon,nwhite,ncolbox,ncolbrd, &
         ncolion,ncolelec,ncollin,ncollab,ncolln2
      common/boundcom/rhoplasm
      common/zoom/ xmaxz, xminz, ymaxz

      real xmaxz, xminz, ymaxz

!      real exkmod(nkpltdim, mkpltdim),
!     .     eykmod(nkpltdim, mkpltdim),
!     .     ezkmod(nkpltdim, mkpltdim)

!      real exklog(nkpltdim, mkpltdim),
!     .     eyklog(nkpltdim, mkpltdim),
!     .     ezklog(nkpltdim, mkpltdim)

!      real exklogmin, exklogmax,
!     .     eyklogmin, eyklogmax,
!     .     ezklogmin, ezklogmax

!      complex exk(nkdim1 : nkdim2, mkdim1 : mkdim2),
!     .        eyk(nkdim1 : nkdim2, mkdim1 : mkdim2),
!     .        ezk(nkdim1 : nkdim2, mkdim1 : mkdim2)

!      real redotj1(nxmx, nymx), redotj2(nxmx, nymx), redotj3(nxmx, nymx)
!      real redotje(nxmx, nymx), redotjt(nxmx, nymx)

!      real wdoti1(nxmx, nymx), wdoti2(nxmx, nymx), wdoti3(nxmx, nymx)
!      real wdote(nxmx, nymx), wdott(nxmx, nymx)


      real fmin, fmax, fminre, fmaxre, fminim, fmaxim, fmin1, &
         fmax1, fmax2, fmax3, fmaxt, fmin2, fmin3, fmint
      real x(nxmx), capr(nxmx), y(nymx), xn(nxmx, nymx)
      real xkti(nxmx, nymx), xkte(nxmx, nymx)
      real rho(nxmx, nymx), theta(nxmx, nymx)
      real xjy(nxmx, nymx), bmod(nxmx, nymx)
      real bmod_mid(nxmx, nymx), capr_bpol_mid2(nxmx, nymx)
      real xjx(nxmx, nymx), psi(nxmx, nymx)
      real xiota(nxmx, nymx), qsafety(nxmx, nymx)
      real btau(nxmx, nymx), bzeta(nxmx, nymx)

      real dbxdx(nxmx, nymx), dbydx(nxmx, nymx), dbzdx(nxmx, nymx), &
           dbxdy(nxmx, nymx), dbydy(nxmx, nymx), dbzdy(nxmx, nymx), &
           dbdx(nxmx, nymx),  dbdy(nxmx, nymx)

      real gradprlb(nxmx, nymx)

      real psizz(nxmx, nymx), psirr(nxmx, nymx), psirz(nxmx, nymx)




      complex adisp(nxmx, nymx), acold(nxmx, nymx)
      real freal(nxmx, nymx), fimag(nxmx, nymx), fmod(nxmx, nymx)

      complex ex(nxmx, nymx), ey(nxmx, nymx), ez(nxmx, nymx)
      complex erho(nxmx, nymx), eeta(nxmx, nymx), eb(nxmx, nymx)
      real spx(nxmx, nymx), spy(nxmx, nymx), spz(nxmx, nymx)

      real xnmid(nxmx), xktimid(nxmx),  xktemid(nxmx), qmid(nxmx)
      real bpmid(nxmx), xiotamid(nxmx)
      real fmidre(nxmx), fmidim(nxmx), fmid1(nxmx), &
           fmid2(nxmx), fmid3(nxmx), fmidt(nxmx)
      real ff(101)
      real q, omgrf, xk0, n0, clight, xmu0, eps0, rhoplasm
      real temax, temin, timin, tmin, tmax, timax, caprmaxp, &
         caprmin, caprminp, caprmax, xnmax, xnmin, qmin, qmax
      real bpmin, bpmax
      integer nnodex, j, i, nnodey, numb, jmid, nxeqd
      complex zi

      namelist/plotin/ibackground, xminz, xmaxz, ymaxz, logmax


!--set default values of input data:
      ibackground = 1
      xminz = 0.51
      xmaxz = 0.62
      ymaxz = 0.24
      logmax = 2.0

! <<  input data
!      read (63, plotin)

      open(unit=138,file='out138',status='old',form='formatted')

!      open(unit=53,file='out53',status='unknown',form='formatted')
!      open(unit=58,file='out58',status='unknown',form='formatted')
!      open(unit=52,file='out52',status='unknown',form='formatted')
!      open(unit=59,file='out59',status='unknown',form='formatted')

!      open(unit=51,file='rho',status='unknown',form='formatted')
!      open(unit=54,file='movie_spx',status='unknown',form='formatted')
!      open(unit=55,file='movie_spy',status='unknown',form='formatted')
!      open(unit=56,file='movie_spz',status='unknown',form='formatted')


!      open(unit=57,file='emodes',status='unknown',form='formatted')

!      open(unit=60,file='test',status='unknown',form='formatted')



      zi = cmplx(0.0, 1.0)
      eps0 = 8.85e-12
      xmu0 = 1.26e-06
      clight = 1./sqrt(eps0 * xmu0)
      xk0 = omgrf / clight
      q = 1.6e-19


!--For white background set ibackground = 0
!      ibackground = 0

!--For black background set ibackground = 1
!      ibackground = 1

!      read(63, 309)ibackground

      read(138, 309) nnodex, nnodey, nxeqd
      read(138, 310) rhoplasm
      read(138, 310) (x(i), i = 1, nnodex)
      read(138, 310) (y(j), j = 1, nnodey)
      read(138, 310) (capr(i), i = 1, nnodex)


      read(138, 310) ((theta(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((bmod(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((rho(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((psi(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((qsafety(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((btau(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((bzeta(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((dbxdx(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dbydx(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dbzdx(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((dbxdy(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dbydy(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dbzdy(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((dbdx(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dbdy(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((psizz(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((psirr(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((psirz(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) (psigrid(i), i = 1, nxeqd)
      read(138, 310) (rhoeqdsk(i), i = 1, nxeqd)
      read(138, 310) (qpsi(i), i = 1, nxeqd)

      read(138, 310) ((dxxbxn(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dxxbyn(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dxxbzn(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((dxybxn(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dxybyn(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dxybzn(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((dyybxn(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dyybyn(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dyybzn(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((dxxmodb(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dxymodb(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((dyymodb(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((gradprlb(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 310) ((bmod_mid(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((capr_bpol_mid2(i, j), i = 1,nnodex), j= 1,nnodey)

      read(138, 309) nnoderho
      read(138, 310) (rhon(n), n = 1, nnoderho)
      read(138, 310) (capr_bpol_midavg(n), n = 1, nnoderho)
      read(138, 310) (bmod_midavg(n), n = 1, nnoderho)

      read(138, 310) ((rho_tor2d(i, j), i = 1, nnodex), j = 1, nnodey)

      read(138, 309) n_phi_max
      read(138, 310) (capr_x(n_phi), n_phi = 1, n_phi_max)
      read(138, 310) (capz_x(n_phi), n_phi = 1, n_phi_max)

      read(138, 310) ((dldb_tot12(i, j), i = 1, nnodex), &
                                        j = 1, nnodey)

      read(138, 310) (dldbavg(n), n = 1, nnoderho)

      read(138, 310) ((bx(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((by(i, j), i = 1, nnodex), j = 1, nnodey)
      read(138, 310) ((bz(i, j), i = 1, nnodex), j = 1, nnodey)

      close (138)

      nnoderho_half = nnoderho - 1

      do n = 1, nnoderho_half
       rhon_half(n) = (rhon(n) + rhon(n+1)) / 2.
      end do


!      write(6, 310) (capr(i), i = 1, nnodex)
!      write(6, 310) ((bmod(i, j), i = 1, nnodex), j = 1, nnodey)

!      write(52,309) nnodex, nnodey
!      write(52,310) ((rho(i, j), i = 1, nnodex), j = 1, nnodey)

!      write(53,309) nnodex, nnodey
!      write(53,310) ((theta(i, j), i = 1, nnodex), j = 1, nnodey)

!      write(58,309) nnodex, nnodey
!      write(58,310) ((bmod(i, j), i = 1, nnodex), j = 1, nnodey)


      jmid = nnodey / 2
      do i = 1, nnodex
         xnmid(i) = xn(i, jmid)
         xktemid(i) = xkte(i, jmid) / q
         xktimid(i) = xkti(i, jmid) / q
         qmid(i) = qsafety(i, jmid)
         xiotamid(i) = 1.0 / qmid(i)
         bpmid(i) = btau(i, jmid)
      end do



      nwhite = 0
      nblack = 1
      nred = 2
      ngreen = 3
      nblue = 4
      ncyan = 5
      nmagenta = 6
      nyellow = 7
      norange = 8

      ncollin=ncyan
      ncolln2=nblueviolet
      ncolln3=ngreen
      ncolln4=naqua
      ncolln5=nyellow
      ncolbrd=nwheat
      ncollab=ncyan

      ncolbox=nred
      ncolbrd=nwheat
!     ncolbox=nblack
!     ncolbrd=nblack

!     ncolion=nblue
!     ncolelec=nred
      ncolion=naqua
      ncolelec=nyellow

      if (ibackground.eq.1)then
         ncolbox=nred
         ncolbrd=nwheat
      end if

      if (ibackground.eq.0)then
         ncolbox=nblack
         ncolbrd=nblack
      end if

! Open graphics device

!      IER = PGBEG(0, 'eqdsk_setup.ps/cps', 2, 2)
      IER = PGBEG(0, 'eqdsk_setup.ps/vcps', 1, 1)

      IF (IER.NE.1) STOP

!      if (pgopen('eqdsk_setup.cps/cps') .lt. 1) stop

      call PGSCH (1.5)


!--Contour plots using 16 contour levels:

      if (ibackground.eq.1)then
!        black background
         ncollin = ncyan
         ncolln2 = nblueviolet
      end if

      if (ibackground.eq.0)then
!        white background
         ncollin = nblue
         ncolln2 = nyellow
      end if

      titx = 'R (m)'
      tity = 'Y (m)'

      numb = 20
      title = 'poloidal rho surfaces'
      call ezconc(capr, y, rho, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)


      CALL PGSCI(nred)
      call pgline(n_phi_max, capr_x, capz_x)


      title = 'toroidal rho surfaces'
      call ezconc(capr, y, rho_tor2d, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)



      title = 'psi surfaces'
      call ezconc(capr, y, psi, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

!      numb = 99

      title = 'dl/B surfaces'
      call ezconc(capr, y, dldb_tot12, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)


      numb = 20

      title = 'q surfaces'
      call ezconc(capr, y, qsafety, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)


      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j)   = 1.0 / bmod(i,j)
         end do
      end do

!      numb = 10

      title = 'Mod 1/B surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)


      title = 'bmod_mid surfaces'
      call ezconc(capr, y, bmod_mid, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)


      title = 'capr_bpol_mid2 surfaces'
      call ezconc(capr, y, capr_bpol_mid2, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)



      do i = 1, nnodex
         fmid1(i) = bx(i, jmid)
      end do

      title= 'Midplane B_x'
      titll= 'B (T)'
      titlr= ' '
      titlb= 'R (m)'

      call ezplot1q(title, titll, titlr, titlb, capr, fmid1, &
         nnodex, nxmx)


      do i = 1, nnodex
         fmid1(i) = by(i, jmid)
      end do

      title= 'Midplane B_y'
      titll= 'B (T)'
      titlr= ' '
      titlb= 'R (m)'

      call ezplot1q(title, titll, titlr, titlb, capr, fmid1, &
         nnodex, nxmx)


      do i = 1, nnodex
         fmid1(i) = bz(i, jmid)
      end do

      title= 'Midplane B_z'
      titll= 'B (T)'
      titlr= ' '
      titlb= 'R (m)'

      call ezplot1q(title, titll, titlr, titlb, capr, fmid1, &
         nnodex, nxmx)


      title= 'Flux average bmod_mid'
      titll= 'bmod_mid (T)'
      titlr='       '
      call ezplot1(title, titll, titlr, rhon_half, bmod_midavg, &
          nnoderho_half, nrhomax)


      title= 'Flux average capr_bpol'
      titll= 'capr_bpol (mT)'
      titlr='       '
      call ezplot1(title, titll, titlr, rhon_half, capr_bpol_midavg, &
           nnoderho_half, nrhomax)

!      do n = 1, nnoderho
!         write(6,*)n, dldbavg(n)
!      end do


      title= 'Integral dl/B'
      titll= 'Integral dl/B (m)'
      titlr='       '

      call ezplot1_0(title, titll, titlr, rhon_half, dldbavg, &
          nnoderho_half, nrhomax)







      numb = 15



      title = 'B poloidal'
      call ezconc(capr, y, btau, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary (capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      title='3-D plot of B poloidal'
      titz='Bpol'
!      call ezcon3d(capr, y, btau, ff, nnodex, nnodey, numb,
!     1   nxmx, nymx, nlevmax, title, titx, tity, titz)


      title = 'B toroidal'
      call ezconc(capr, y, bzeta, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary (capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      title='3-D plot of B toroidal'
      titz='Btor'
!      call ezcon3d(capr, y, bzeta, ff, nnodex, nnodey, numb,
!     1   nxmx, nymx, nlevmax, title, titx, tity, titz)



      title = 'grad_parallel B'
      call ezconc(capr, y, gradprlb, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
      if (iflag .eq. 0) call boundary (capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      title='3-D plot of gradprlb'
      titz='gradprlb'
!      call ezcon3d(capr, y, gradprlb, ff, nnodex, nnodey, numb,
!     1   nxmx, nymx, nlevmax, title, titx, tity, titz)



!
!--plot q profile in midplane
!

      call a1mnmx(capr, nxmx, nnodex, caprmin, caprmax)
      caprminp = caprmin * 1.01
      caprmaxp = caprmax * .99

      call a2mnmx(qmid, nxmx, nnodex, &
         capr, caprminp, caprmaxp, qmin, qmax)
      qmin = 0.0
!     qmax = 5.0

      CALL PGPAGE
      CALL PGSVP (0.15,0.85,0.15,0.85)
      CALL PGSWIN (caprmin, caprmax, qmin, qmax)
      CALL PGBOX  ('BCNST', 0.0, 0, 'BNST', 0.0, 0)
      call pgmtxt('b', 3.2, 0.5, 0.5, 'R (m)')
      call pgmtxt('t', 2.0, 0.5, 0.5, 'q profile in midplane')

      CALL PGSCI(nred)
      call pgmtxt('l', 2.0, 0.5, 0.5, 'q midplane')
      call pgline(nnodex, capr, qmid)

      CALL PGSCI(nblue)
      call pgsls(2)
      call pgline(nnodex, capr, xiotamid)

      call a1mnmx(bpmid, nxmx, nnodex, bpmin, bpmax)
      bpmin = 0.0

      CALL PGSWIN (caprmin, caprmax, bpmin, bpmax)
      CALL PGSCI(nblack)
      CALL PGBOX  (' ', 0.0, 0, 'CMST', 0.0, 0)

      CALL PGSCI(ngreen)
      call pgsls(3)
      call pgline(nnodex, capr, bpmid)
      call PGMTXT ('r', 2.0, 0.5, 0.5, 'btau')

      CALL PGSCI(nblack)
      call pgsls(1)



      numb = 50

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dbxdx(i,j)
         end do
      end do

      title = 'dbxdx surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dbydx(i,j)
         end do
      end do

      title = 'dbydx surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dbzdx(i,j)
         end do
      end do

      title = 'dbzdx surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dbxdy(i,j)
         end do
      end do

      title = 'dbxdy surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dbydy(i,j)
         end do
      end do

      title = 'dbydy surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dbzdy(i,j)
         end do
      end do

      title = 'dbzdy surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dbdx(i,j)
         end do
      end do

      title = 'dbdx surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dbdy(i,j)
         end do
      end do

      title = 'dbdy surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dxxbxn(i,j)
         end do
      end do

      title = 'dxxbxn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dxxbyn(i,j)
         end do
      end do

      title = 'dxxbyn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dxxbzn(i,j)
         end do
      end do

      title = 'dxxbzn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)




      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dxybxn(i,j)
         end do
      end do

      title = 'dxybxn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dxybyn(i,j)
         end do
      end do

      title = 'dxybyn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dxybzn(i,j)
         end do
      end do

      title = 'dxybzn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)




      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dyybxn(i,j)
         end do
      end do

      title = 'dyybxn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dyybyn(i,j)
         end do
      end do

      title = 'dyybyn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dyybzn(i,j)
         end do
      end do

      title = 'dyybzn surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)




      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dxxmodb(i,j)
         end do
      end do

      title = 'dxxmodb surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dxymodb(i,j)
         end do
      end do

      title = 'dxymodb surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)

      do i = 1, nnodex
         do j = 1, nnodey
            fmod(i,j) = dyymodb(i,j)
         end do
      end do

      title = 'dyymodb surfaces'
      call ezconc(capr, y, fmod, ff, nnodex, nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity, iflag)
       if (iflag .eq. 0) call boundary(capr, y, rho, ff, nnodex, &
         nnodey, numb, &
         nxmx, nymx, nlevmax, title, titx, tity)


! Close the graphics device.

      call pgclos



  310 format(1p6e12.4)
  309 format(10i10)
  311 format(1p10e12.4)
 1312 format(i10,1p8e12.4)
 1313 format(2i10,1p8e12.4)
 9310 format(1p7e12.4)
   10 format(i10,1p4e10.3,i10,1pe10.3)

      return
      end subroutine eqdsk_plot
!
!********************************************************************
!

!----------------------------------------------------------------------------!
! Subroutine a2dmnmx_eq
!----------------------------------------------------------------------------!
! Minimum and the maximum elements of a 2-d array.
!----------------------------------------------------------------------------!

      subroutine a2dmnmx_eq(f, nxmax, nymax, nx, ny, fmin, fmax)

      implicit none

      integer nx, ny, i, j, nxmax, nymax
      real f(nxmax, nymax), fmin, fmax

      fmax=f(2, 1)
      fmin=fmax
      do 23000 j=1, ny
!         do 23002 i=1, nx
         do 23002 i=2, nx-1
            fmax=amax1(fmax, f(i, j))
            fmin=amin1(fmin, f(i, j))
23002    continue
23000 continue

      return
 2201 format(2i5,1p8e12.4)
      end subroutine a2dmnmx_eq

end module eqdsk_plot_mod
