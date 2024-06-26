! This file is part of dftd4.
! SPDX-Identifier: LGPL-3.0-or-later
!
! dftd4 is free software: you can redistribute it and/or modify it under
! the terms of the Lesser GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! dftd4 is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! Lesser GNU General Public License for more details.
!
! You should have received a copy of the Lesser GNU General Public License
! along with dftd4.  If not, see <https://www.gnu.org/licenses/>.

subroutine calc_dftd4_rest(num, num_size, xyz, charge, uhf, method_c, method_len, energy, final_gradient, final_sigma)
   use mctc_env
   use mctc_io
   use dftd4
   implicit none

   integer, intent(in) :: num_size
   integer, intent(in) :: num(num_size)
   real(wp), intent(in) :: xyz(3, num_size)
   real(wp), intent(in) :: charge
   integer, intent(in) :: uhf
   character(len=100), intent(in) :: method_c
   integer, intent(in) :: method_len
   character(len=100) :: method

   type(structure_type) :: mol
   real(wp), allocatable :: gradient(:,:)
   real(wp), allocatable :: sigma(:,:)
   type(d4_model) :: disp
   class(damping_param), allocatable :: param

   real(wp), allocatable :: xyz_m(:, :)

   real(wp), intent(out) :: energy
   real(wp), intent(out) :: final_gradient(3, num_size)
   real(wp), intent(out) :: final_sigma(3, num_size)

   !strip the method and corr
   method = method_c(1:method_len)

   !turn the float array into wp array
   xyz_m = reshape(xyz, [3, num_size])

   call new(mol, num, xyz_m, charge, uhf)

   allocate(gradient(3, num_size), sigma(3, num_size))

   call new_d4_model(disp, mol)

   call get_rational_damping(method, param, s9=1.0_wp)

   call get_dispersion(mol, disp, param, realspace_cutoff(), energy, gradient, sigma)

   final_gradient = gradient
   final_sigma = sigma

end subroutine calc_dftd4_rest

