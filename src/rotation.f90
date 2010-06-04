modUle rotation

implicit none

real, allocatable, dimension(:,:) :: bPol
real :: sqx

real, allocatable, dimension(:,:) :: &
    Urr, Urt, Urz, Utr, Utt, Utz, Uzr, Uzt, Uzz

real, allocatable, dimension(:,:,:,:) :: U_RTZ_to_ABb

real, allocatable :: sinTh(:,:)
real, allocatable, dimension(:,:) :: gradPrlB

! dr first derivatives
real, allocatable, dimension(:,:) :: &
    drUrr, drUrt, drUrz, &
    drUtr, drUtt, drUtz, &
    drUzr, drUzt, drUzz

! dz first derivatives
real, allocatable, dimension(:,:) :: &
    dzUrr, dzUrt, dzUrz, &
    dzUtr, dzUtt, dzUtz, &
    dzUzr, dzUzt, dzUzz

! drr second derivatives
real, allocatable, dimension(:,:) :: &
    drrUrr, drrUrt, drrUrz, &
    drrUtr, drrUtt, drrUtz, &
    drrUzr, drrUzt, drrUzz

! dzz second derivatives
real, allocatable, dimension(:,:) :: &
    dzzUrr, dzzUrt, dzzUrz, &
    dzzUtr, dzzUtt, dzzUtz, &
    dzzUzr, dzzUzt, dzzUzz

!drz derivatives
real, allocatable, dimension(:,:) :: &
    drzUrr, drzUrt, drzUrz, &
    drzUtr, drzUtt, drzUtz, &
    drzUzr, drzUzt, drzUzz

contains

    subroutine init_rotation ()

        use aorsa2din_mod, &
        only: nPtsX, nPtsY
        use bField
        use grid, &
        only: capR, y

        implicit none

        integer :: i,j 
        real, allocatable :: sqr(:,:)
        real, allocatable :: det(:,:)

        allocate ( sqr ( nPtsx, nPtsY ) )
        allocate ( bPol ( nPtsX, nPtsY ) )

        
        ! Create a cylindrical coordinate version of the 
        ! rotation matrix so we have some consistency in the
        ! naming conventions of coordinates and hence preserve
        ! what is left of my sanity

        allocate ( &
            Urr( nPtsX, nPtsY ), & 
            Urt( nPtsX, nPtsY ), &
            Urz( nPtsX, nPtsY ), &
            Utr( nPtsX, nPtsY ), & 
            Utt( nPtsX, nPtsY ), &
            Utz( nPtsX, nPtsY ), &
            Uzr( nPtsX, nPtsY ), & 
            Uzt( nPtsX, nPtsY ), &
            Uzz( nPtsX, nPtsY ) )

        sqr     = sqrt ( 1d0 - brn_**2 )

        Urr     = sqr
        Urt    = -brn_ * bthn_ / sqr
        Urz     = -brn_ * bzn_ / sqr

        Utr    = 0
        Utt   = bzn_ / sqr
        Utz    = -bthn_ / sqr

        Uzr     = brn_
        Uzt    = bthn_
        Uzz     = bzn_


        ! Check the determinant, should = 1
        ! ---------------------------------
    
        allocate(det(nPtsX,nPtsY))

        det = Urr * Utt * Uzz &
            + Urt * Utz * Uzr &
            + Urz * Utr * Uzt &
            - Urr * Utz * Uzt &
            - Urt * Utr * Uzz &
            - Urz * Utt * Uzr

        if ( any(1-det>1e-4) ) then

            write(*,*) 'rotation.f90: ERROR det != 1'
            stop

        endif

        deallocate(det)

        allocate ( U_RTZ_to_ABb(nPtsX,nPtsY,3,3) )

        U_RTZ_to_ABb(:,:,1,1)  = Urr
        U_RTZ_to_ABb(:,:,1,2)  = Urt
        U_RTZ_to_ABb(:,:,1,3)  = Urz
        
        U_RTZ_to_ABb(:,:,2,1)  = Utr
        U_RTZ_to_ABb(:,:,2,2)  = Utt
        U_RTZ_to_ABb(:,:,2,3)  = Utz

        U_RTZ_to_ABb(:,:,3,1)  = Uzr
        U_RTZ_to_ABb(:,:,3,2)  = Uzt
        U_RTZ_to_ABb(:,:,3,3)  = Uzz

    end sUbroUtine init_rotation


    sUbroUtine deriv_rotation

        Use aorsa2din_mod, &
        only: nPtsX, nPtsY, nZFUn, r0
        Use grid
        Use derivatives 
        Use bField
        Use eqdsk_dlg

        implicit none

        integer :: i, j
        real :: distance

        allocate ( gradPrlB (nPtsX,nPtsY), sinTh(nPtsX,nPtsY) )
        gradPrlB = 0

        do i = 1, nPtsX
            do j = 1, nPtsY

                ! Brambillas approximation to dBdPar
                ! ----------------------------------

                distance = sqrt ( (capR(i)-r0)**2 + y(j)**2 )
                if ( distance > 0 ) then

                    sinTh(i,j) =  y(j) / distance
                    gradPrlB(i,j) = bMod(i,j) / capR(i) * abs ( bPol(i,j) * sinTh(i,j) )

                else ! on magnetic axis (r=r0, y=y0=0)

                    gradPrlB(i,j) = 0

                endif

                !if (nzfUn == 0) gradPrlB(i,j) = 1.0e-10

           enddo
        enddo

        ! R,Th,z version
        ! --------------

        allocate ( &
            drUrr(nPtsX,nPtsY), drrUrr(nPtsX,nPtsY), &
            drUrt(nPtsX,nPtsY), drrUrt(nPtsX,nPtsY), &
            drUrz(nPtsX,nPtsY), drrUrz(nPtsX,nPtsY), &
            drUtr(nPtsX,nPtsY), drrUtr(nPtsX,nPtsY), &
            drUtt(nPtsX,nPtsY), drrUtt(nPtsX,nPtsY), &
            drUtz(nPtsX,nPtsY), drrUtz(nPtsX,nPtsY), &
            drUzr(nPtsX,nPtsY), drrUzr(nPtsX,nPtsY), &
            drUzt(nPtsX,nPtsY), drrUzt(nPtsX,nPtsY), &
            drUzz(nPtsX,nPtsY), drrUzz(nPtsX,nPtsY) )

        allocate ( &
            dzUrr(nPtsX,nPtsY), dzzUrr(nPtsX,nPtsY), &
            dzUrt(nPtsX,nPtsY), dzzUrt(nPtsX,nPtsY), &
            dzUrz(nPtsX,nPtsY), dzzUrz(nPtsX,nPtsY), &
            dzUtr(nPtsX,nPtsY), dzzUtr(nPtsX,nPtsY), &
            dzUtt(nPtsX,nPtsY), dzzUtt(nPtsX,nPtsY), &
            dzUtz(nPtsX,nPtsY), dzzUtz(nPtsX,nPtsY), &
            dzUzr(nPtsX,nPtsY), dzzUzr(nPtsX,nPtsY), &
            dzUzt(nPtsX,nPtsY), dzzUzt(nPtsX,nPtsY), &
            dzUzz(nPtsX,nPtsY), dzzUzz(nPtsX,nPtsY) )

        allocate ( &
            drzUrr(nPtsX,nPtsY), drzUrt(nPtsX,nPtsY), drzUrz(nPtsX,nPtsY), &
            drzUtr(nPtsX,nPtsY), drzUtt(nPtsX,nPtsY), drzUtz(nPtsX,nPtsY), &
            drzUzr(nPtsX,nPtsY), drzUzt(nPtsX,nPtsY), drzUzz(nPtsX,nPtsY) ) 

        do i = 1, nPtsX
            do j = 1, nPtsY

                call deriv_x(capR, Urr, i, j, dfdx = drUrr(i,j), d2fdx2 = drrUrr(i,j))
                call deriv_x(capR, Urt, i, j, dfdx = drUrt(i,j), d2fdx2 = drrUrt(i,j))
                call deriv_x(capR, Urz, i, j, dfdx = drUrz(i,j), d2fdx2 = drrUrz(i,j))

                call deriv_x(capR, Utr, i, j, dfdx = drUtr(i,j), d2fdx2 = drrUtr(i,j))
                call deriv_x(capR, Utt, i, j, dfdx = drUtt(i,j), d2fdx2 = drrUtt(i,j))
                call deriv_x(capR, Utz, i, j, dfdx = drUtz(i,j), d2fdx2 = drrUtz(i,j))

                call deriv_x(capR, Uzr, i, j, dfdx = drUzr(i,j), d2fdx2 = drrUzr(i,j))
                call deriv_x(capR, Uzt, i, j, dfdx = drUzt(i,j), d2fdx2 = drrUzt(i,j))
                call deriv_x(capR, Uzz, i, j, dfdx = drUzz(i,j), d2fdx2 = drrUzz(i,j))

                call deriv_y(y, Urr, i, j, dfdy = drUrr(i,j), d2fdy2 = drrUrr(i,j))
                call deriv_y(y, Urt, i, j, dfdy = drUrt(i,j), d2fdy2 = drrUrt(i,j))
                call deriv_y(y, Urz, i, j, dfdy = drUrz(i,j), d2fdy2 = drrUrz(i,j))

                call deriv_y(y, Utr, i, j, dfdy = drUtr(i,j), d2fdy2 = drrUtr(i,j))
                call deriv_y(y, Utt, i, j, dfdy = drUtt(i,j), d2fdy2 = drrUtt(i,j))
                call deriv_y(y, Utz, i, j, dfdy = drUtz(i,j), d2fdy2 = drrUtz(i,j))

                call deriv_y(y, Uzr, i, j, dfdy = drUzr(i,j), d2fdy2 = drrUzr(i,j))
                call deriv_y(y, Uzt, i, j, dfdy = drUzt(i,j), d2fdy2 = drrUzt(i,j))
                call deriv_y(y, Uzz, i, j, dfdy = drUzz(i,j), d2fdy2 = drrUzz(i,j))

                call deriv_xy(capR, y, Urr, i, j, d2fdxy = drzUrr(i,j))
                call deriv_xy(capR, y, Urt, i, j, d2fdxy = drzUrt(i,j))
                call deriv_xy(capR, y, Urz, i, j, d2fdxy = drzUrz(i,j))

                call deriv_xy(capR, y, Utr, i, j, d2fdxy = drzUtr(i,j))
                call deriv_xy(capR, y, Utt, i, j, d2fdxy = drzUtt(i,j))
                call deriv_xy(capR, y, Utz, i, j, d2fdxy = drzUtz(i,j))

                call deriv_xy(capR, y, Uzr, i, j, d2fdxy = drzUzr(i,j))
                call deriv_xy(capR, y, Uzt, i, j, d2fdxy = drzUzt(i,j))
                call deriv_xy(capR, y, Uzz, i, j, d2fdxy = drzUzz(i,j))

           enddo
        enddo

        !drUrr =0 
        !drUrt =0 
        !drUrz =0 

        !drUtr =0 
        !drUtt =0 
        !drUtz =0 

        !drUzr =0 
        !drUzt =0 
        !drUzz =0 

        !drUrr =0 
        !drUrt =0 
        !drUrz =0 

        !drUtr =0 
        !drUtt =0 
        !drUtz =0 

        !drUzr =0 
        !drUzt =0 
        !drUzz =0 

        !drrUrr=0 
        !drrUrt=0
        !drrUrz=0

        !drrUtr=0
        !drrUtt=0
        !drrUtz=0

        !drrUzr=0
        !drrUzt=0
        !drrUzz=0

        !drrUrr=0
        !drrUrt=0
        !drrUrz=0

        !drrUtr=0
        !drrUtt=0
        !drrUtz=0

        !drrUzr=0
        !drrUzt=0
        !drrUzz=0

        !drzUrr=0 
        !drzUrt=0
        !drzUrz=0

        !drzUtr=0
        !drzUtt=0
        !drzUtz=0

        !drzUzr=0
        !drzUzt=0
        !drzUzz=0

    end subroutine deriv_rotation

end module rotation
