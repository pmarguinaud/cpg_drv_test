#!/usr/bin/perl -w

use strict;

my $fc = '/home/gmap/mrpm/khatib/public/bin/mimpifc-18.0.5.274';

my @f1 = qw (
mf_phys_bayrad.F90
mf_phys_bayrad_parallel.F90
mf_phys.F90
mf_phys_fpl_part1.F90
mf_phys_fpl_part1_parallel.F90
mf_phys_fpl_part2.F90
mf_phys_fpl_part2_parallel.F90
mf_phys_init.F90
mf_phys_init_parallel.F90
mf_phys_mocon.F90
mf_phys_mocon_parallel.F90
mf_phys_parallel.F90
mf_phys_precips.F90
mf_phys_precips_parallel.F90
mf_phys_prep.F90
mf_phys_prep_parallel.F90
mf_phys_save_phsurf_part1.F90
mf_phys_save_phsurf_part1_parallel.F90
mf_phys_save_phsurf_part2.F90
mf_phys_save_phsurf_part2_parallel.F90
mf_phys_transfer.F90
mf_phys_transfer_parallel.F90

acevadcape.F90
acevadcape_openacc.F90
acevolet.F90
acevolet_openacc.F90

acdrag.F90
acdrag_openacc.F90
acdrme.F90
acdrme_openacc.F90

acbl89.F90
acbl89_openacc.F90

accldia.F90
accldia_openacc.F90
acclph.F90
acclph_openacc.F90

actke.F90
actke_openacc.F90

);

my @f0 = qw (
suozon.F90
suozon_openacc.F90
ppwetpoint.F90
ppwetpoint_openacc.F90
qngcor.F90
qngcor_openacc.F90
radozcmf.F90
radozcmf_openacc.F90
hl2fl.F90
hl2fl_openacc.F90
fl2hl.F90
fl2hl_openacc.F90
dprecips.F90
dprecips_openacc.F90
cpphinp.F90
cpphinp_openacc.F90
acctnd0.F90
acctnd0_parallel.F90
acdnshf.F90
acdnshf_openacc.F90
achmt.F90
achmtls.F90
achmtls_openacc.F90
achmt_openacc.F90
aclender.F90
aclender_openacc.F90
acntcls.F90
acntcls_openacc.F90
acpluis.F90
acpluis_openacc.F90
acsol.F90
acsol_openacc.F90
acsolw.F90
acsolw_openacc.F90
actqsat.F90
actqsat_openacc.F90
acturb.F90
acturb_openacc.F90
acvisih.F90
acvisih_openacc.F90
apl_arpege_aerosols_for_radiation.F90
apl_arpege_aerosols_for_radiation_parallel.F90
apl_arpege_albedo_computation.F90
apl_arpege_albedo_computation_parallel.F90
apl_arpege_atmosphere_update.F90
apl_arpege_atmosphere_update_parallel.F90
apl_arpege_cloudiness.F90
apl_arpege_cloudiness_parallel.F90
apl_arpege_deep_convection.F90
apl_arpege_deep_convection_parallel.F90
apl_arpege_dprecips.F90
apl_arpege_dprecips_parallel.F90
apl_arpege.F90
apl_arpege_hydro_budget.F90
apl_arpege_hydro_budget_parallel.F90
apl_arpege_init.F90
apl_arpege_init_parallel.F90
apl_arpege_init_surfex.F90
apl_arpege_init_surfex_parallel.F90
apl_arpege_oceanic_fluxes.F90
apl_arpege_oceanic_fluxes_parallel.F90
apl_arpege_parallel.F90
apl_arpege_precipitation.F90
apl_arpege_precipitation_parallel.F90
apl_arpege_radiation.F90
apl_arpege_radiation_parallel.F90
apl_arpege_shallow_convection_and_turbulence.F90
apl_arpege_shallow_convection_and_turbulence_parallel.F90
apl_arpege_soil_hydro.F90
apl_arpege_soil_hydro_parallel.F90
apl_arpege_surface.F90
apl_arpege_surface_parallel.F90
apl_arpege_surface_update.F90
apl_arpege_surface_update_parallel.F90
aplpar_init.F90
aplpar_init_openacc.F90
apl_wind_gust.F90
apl_wind_gust_parallel.F90
checkmv.F90
checknan.F90
compiler_features.F90
cpg_dia_flu.F90
cpg_drv.F90
cpg.F90
cpg_gp_hyd.F90
cputqy0.F90
cputqy0_parallel.F90
cputqy_aplpar_expl.F90
cputqy_aplpar_expl_parallel.F90
cpxfu.F90
cuadjtq.F90
cuascn.F90
cubasen.F90
cuddrafn.F90
cudlfsn.F90
cududv.F90
cuinin.F90
gpgeo_expl.F90

sigam.F90
sitnu.F90
suehdf.F90
sugfl1.F90
suorog.F90
suspeca.F90
vegtype_grid_to_patch_grid.F90
);


# -g -O0 -init=arrays,snan

my ($f) = grep { m/\.F90/o } @ARGV;

if (grep { $f eq $_ } @f1)
  {
    unshift (@ARGV, '-init=arrays,snan');
  }

my @cmd = ($fc, @ARGV);

print "@cmd\n";

exec (@cmd);

