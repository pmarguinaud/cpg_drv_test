#!/bin/bash

in=src/main
dir=src/local/arpifs/module
no_alloc=FIELD_2D,FIELD_3D,FIELD_4D
module_map=UTIL_FIELD_2D_MOD,UTIL_FIELD_MOD,UTIL_FIELD_3D_MOD,UTIL_FIELD_MOD,UTIL_FIELD_4D_MOD,UTIL_FIELD_MOD

set -x

./scripts/loadsave.pl \
  --load --save --dir $dir $in/arpifs/module/type_fluxes.F90

./scripts/loadsave.pl \
  --load --save --dir $dir --skip-components ./scripts/skip_flu.pl --no-allocate $no_alloc \
  --module-map $module_map \
  $in/.fypp/arpifs/module/yomxfu_type.F90 

./scripts/loadsave.pl \
  --load --save --dir $dir --skip-components ./scripts/skip_flu.pl --no-allocate $no_alloc \
  --module-map $module_map \
  $in/.fypp/arpifs/module/yomcfu_type.F90 

./scripts/loadsave.pl \
  --load --save --dir $dir --skip-components ./scripts/skip_var.pl --no-allocate $no_alloc \
  --module-map $module_map \
  $in/.fypp/arpifs/module/variable_module.F90 

./scripts/loadsave.pl \
  --load --save --dir $dir --skip-components ./scripts/skip_cpg.pl --no-allocate $no_alloc \
  --only-types 'CPG_MISC_TYPE,CPG_DYN_TYPE,CPG_RCP_TYPE,CPG_CTY_TYPE,CPG_HWIND_TYPE,CPG_XYB_TYPE' \
  --module-map $module_map \
  $in/.fypp/arpifs/module/cpg_type_mod.F90

./scripts/loadsave.pl \
  --load --save --dir $dir \
  --only-components 'GEOMETRY_VARIABLES%GM,FIELD_VARIABLES%Q,FIELD_VARIABLES%O3,FIELD_VARIABLES%GEOMETRY' --only-types 'GEOMETRY_VARIABLES,FIELD_VARIABLES' \
  $in/.fypp/arpifs/module/field_variables_mod.F90 

./scripts/loadsave.pl \
  --load --save --dir $dir --skip-components ./scripts/skip_cpg.pl --no-allocate $no_alloc \
  --only-types MF_PHYS_OUT_TYPE \
  --module-map $module_map \
  $in/.fypp/arpifs/module/mf_phys_type_mod.F90

./scripts/loadsave.pl \
  --load --save --dir $dir --out util_cpg_opts_type_mod.F90 \
  --skip-types CPG_BNDS_TYPE \
  $in/.fypp/arpifs/module/cpg_opts_type_mod.F90 

./scripts/loadsave.pl \
  --load --save --dir $dir \
  $in/arpifs/module/yomcli.F90

./scripts/loadsave.pl \
  --load --save --dir $dir \
  --only-types TYPE_SURF_GEN --dir $dir \
  $in/arpifs/module/surface_fields_mix.F90

./scripts/loadsave.pl \
  --load --save --dir $dir --out util_surface_variables_mod.F90 \
  --only-types SURFACE_VARIABLE_GROUP_RESVR --skip-components SURFACE_VARIABLE_GROUP_RESVR%F_GROUP \
  $in/.fypp/arpifs/module/surface_variables_mod.F90

./scripts/loadsave.pl \
  --load --save --only-types SURFACE_VIEW_GROUP_RESVR,SURFACE_VIEW_GROUP_SNOWG,SURFACE_VIEW_GROUP_CLS \
  --dir $dir --out util_surface_views_prognostic_module.F90 \
  --module-map $module_map --no-allocate $no_alloc \
  --skip-components scripts/skip_sfc.pl \
  $in/.fypp/arpifs/module/surface_views_prognostic_module.F90

./scripts/loadsave.pl \
  --load --save --only-types SURFACE_VIEW_GROUP_VPRECIP,SURFACE_VIEW_GROUP_VPRECIP2 \
  --dir $dir --out util_surface_views_diagnostic_module.F90 \
  --module-map $module_map --no-allocate $no_alloc \
  --skip-components scripts/skip_sfc.pl \
  $in/.fypp/arpifs/module/surface_views_diagnostic_module.F90

./scripts/loadsave.pl \
  --load --save --dir $dir \
  --module-map $module_map --no-allocate $no_alloc \
  --only-components 'MF_PHYS_SURF_TYPE%GSP_RR,MF_PHYS_SURF_TYPE%GSP_SG,MF_PHYS_SURF_TYPE%GSD_XP,MF_PHYS_SURF_TYPE%GSD_XP2,MF_PHYS_SURF_TYPE%GSP_CL' \
  $in/.fypp/arpifs/module/mf_phys_surface_type_mod.F90
  
