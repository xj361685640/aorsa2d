module inv_fourier

implicit none

contains

    subroutine sftinv2d( g )

        use aorsa2din_mod, &
        only: chebyshevX, chebyshevY, cosX, cosY, fracOfModesInSolution
        use grid
 
        implicit none

        type(gridBlock), intent(inout) :: g
        
        !complex, intent(in) :: a(:,:)
        !complex, intent(inout), optional, allocatable :: &
        !    f(:,:)

        complex :: bFn
        integer :: i, j, n, m
        integer :: nS, nF, mS, mF

        if (.not. allocated ( g%eAlpha ) ) allocate ( g%eAlpha(g%nR,g%nZ) )
        if (.not. allocated ( g%eBeta ) ) allocate ( g%eBeta(g%nR,g%nZ) )
        if (.not. allocated ( g%eB ) ) allocate ( g%eB(g%nR,g%nZ) )

        !f = 0
        g%eAlpha = 0
        g%eBeta = 0
        g%eB = 0

        if(chebyshevX)then
            g%nS = g%nMin
            g%nF = g%nMax
        elseif(cosX)then
            g%nS = g%nMin
            g%nF = g%nMax
        else
            g%nS = g%nMin*fracOfModesInSolution
            g%nF = g%nMax*fracOfModesInSolution
        endif

        if(chebyshevY)then
            g%mS = g%mMin
            g%mF = g%mMax
        elseif(cosY)then
            g%mS = g%mMin
            g%mF = g%mMax
        else
            g%mS = g%mMin*fracOfModesInSolution
            g%mF = g%mMax*fracOfModesInSolution
            if(g%nZ==1)then
                g%mS = g%mMin
                g%mF = g%mMax
            endif
        endif


        ! NOTE: There may be an indexing error here after changing to the g
        ! type routine. If so it means the g%eAlphak etc have retained their
        ! neg through pos indexing that was not retained in the previous
        ! approach.

        do i = 1, g%nR
            do j = 1, g%nZ
        
                do n = g%nS, g%nF
                    do m = g%mS, g%mF

                      !bFn = xBasis(n,g%rNorm(i)) * yBasis(m,g%zNorm(j))
                      bFn = g%xx(n,i) * g%yy(m,j)

                      !f(i,j) = f(i,j) + a(n-nMin+1,m-mMin+1) * bFn
                      g%eAlpha(i,j) = g%eAlpha(i,j) + g%eAlphak(n,m) * bFn
                      g%eBeta(i,j) = g%eBeta(i,j) + g%eBetak(n,m) * bFn
                      g%eB(i,j) = g%eB(i,j) + g%eBk(n,m) * bFn

                    enddo
                enddo

            enddo
        enddo
    
    
    end subroutine sftinv2d

end module inv_fourier

