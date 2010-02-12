module write_data

use netcdf

contains

    subroutine write_runData ( fName, x, y, bx, by, bz, bmod, jy )
    
        implicit none

        character(len=*), intent(in) :: fName 
        real, intent(in), dimension(:) :: &
            x, y
        real, intent(in), dimension(:,:) :: &
            bx, by, bz, bmod
        complex, intent(in), dimension(:,:) :: &
            jy

        integer :: nc_id, nX_id, nY_id
        integer :: nX, nY
        integer :: &
            x_id, y_id, &
            bx_id, by_id, bz_id, bmod_id, &
            jy_re_id, jy_im_id

        nX  = size ( bx, 1 )
        nY  = size ( bx, 2 )

        call check ( nf90_create ( fName, nf90_clobber, nc_id ) )
        call check ( nf90_def_dim ( nc_id, "nX", nX, nX_id ) )
        call check ( nf90_def_dim ( nc_id, "nY", nY, nY_id ) )

        call check ( nf90_def_var ( nc_id, "x", NF90_REAL, &
            (/nX_id/), x_id ) ) 
         call check ( nf90_def_var ( nc_id, "y", NF90_REAL, &
            (/nY_id/), y_id ) ) 
 
        call check ( nf90_def_var ( nc_id, "bx", NF90_REAL, &
            (/nX_id,nY_id/), bx_id ) ) 
        call check ( nf90_def_var ( nc_id, "by", NF90_REAL, &
            (/nX_id,nY_id/), by_id ) ) 
        call check ( nf90_def_var ( nc_id, "bz", NF90_REAL, &
            (/nX_id,nY_id/), bz_id ) ) 
        call check ( nf90_def_var ( nc_id, "bmod", NF90_REAL, &
            (/nX_id,nY_id/), bmod_id ) ) 
 
        call check ( nf90_def_var ( nc_id, "jy_re", NF90_REAL, &
            (/nX_id,nY_id/), jy_re_id ) ) 
        call check ( nf90_def_var ( nc_id, "jy_im", NF90_REAL, &
            (/nX_id,nY_id/), jy_im_id ) ) 
 
        call check ( nf90_enddef ( nc_id ) )
        
        call check ( nf90_put_var ( nc_id, x_id, x ) )
        call check ( nf90_put_var ( nc_id, y_id, y ) )

        call check ( nf90_put_var ( nc_id, bx_id, bx ) )
        call check ( nf90_put_var ( nc_id, by_id, by ) )
        call check ( nf90_put_var ( nc_id, bz_id, bz ) )
        call check ( nf90_put_var ( nc_id, bmod_id, bmod ) )
        call check ( nf90_put_var ( nc_id, jy_re_id, real(jy) ) )
        call check ( nf90_put_var ( nc_id, jy_im_id, aimag(jy) ) )

        call check ( nf90_close ( nc_id ) )

    end subroutine write_runData


    subroutine write_solution ( fName, e1, e2, e3 )
    
        implicit none

        character(len=*), intent(in) :: fName 
        complex, intent(in) :: e1(:,:), e2(:,:), e3(:,:)

        integer :: nc_id, nX_id, nY_id
        integer :: nX, nY
        integer :: &
            e1_re_id, e1_im_id, &
            e2_re_id, e2_im_id, &
            e3_re_id, e3_im_id

        nX  = size ( e1, 1 )
        nY  = size ( e1, 2 )

        call check ( nf90_create ( fName, nf90_clobber, nc_id ) )
        call check ( nf90_def_dim ( nc_id, "nX", nX, nX_id ) )
        call check ( nf90_def_dim ( nc_id, "nY", nY, nY_id ) )

        call check ( nf90_def_var ( nc_id, "ealpha_re", NF90_REAL, &
            (/nX_id,nY_id/), e1_re_id ) ) 
        call check ( nf90_def_var ( nc_id, "ealpha_im", NF90_REAL, &
            (/nX_id,nY_id/), e1_im_id ) ) 
        call check ( nf90_def_var ( nc_id, "ebeta_re", NF90_REAL, &
            (/nX_id,nY_id/), e2_re_id ) ) 
        call check ( nf90_def_var ( nc_id, "ebeta_im", NF90_REAL, &
            (/nX_id,nY_id/), e2_im_id ) ) 
        call check ( nf90_def_var ( nc_id, "eB_re", NF90_REAL, &
            (/nX_id,nY_id/), e3_re_id ) ) 
        call check ( nf90_def_var ( nc_id, "eB_im", NF90_REAL, &
            (/nX_id,nY_id/), e3_im_id ) ) 
 
        call check ( nf90_enddef ( nc_id ) )

        call check ( nf90_put_var ( nc_id, e1_re_id, real ( e1 ) ) )
        call check ( nf90_put_var ( nc_id, e1_im_id, aimag ( e1 ) ) )
        call check ( nf90_put_var ( nc_id, e2_re_id, real ( e2 ) ) )
        call check ( nf90_put_var ( nc_id, e2_im_id, aimag ( e2 ) ) )
        call check ( nf90_put_var ( nc_id, e3_re_id, real ( e3 ) ) )
        call check ( nf90_put_var ( nc_id, e3_im_id, aimag ( e3 ) ) )

        call check ( nf90_close ( nc_id ) )

    end subroutine write_solution 


    subroutine check ( status )

            integer, intent(in) :: status
          
            if(status /= nf90_noerr) then 
                print *, trim(nf90_strerror(status))
                stop "Stopped"
            end if
    
    end subroutine check

end module write_data