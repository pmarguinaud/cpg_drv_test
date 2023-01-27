#!/bin/bash

export PATH=/home/gmap/mrpm/marguina/fxtran-acdc/bin:$PATH

generateStructureMethods.pl \
 --field-api --field-api-class info_var src/local/.fypp/arpifs/module/variable_module.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_var src/local/.fypp/arpifs/module/field_variables_mod.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_cpg src/local/.fypp/arpifs/module/mf_phys_type_mod.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_cpg src/local/.fypp/arpifs/module/mf_phys_base_state_type_mod.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_cpg src/local/.fypp/arpifs/module/mf_phys_next_state_type_mod.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_cpg src/local/.fypp/arpifs/module/cpg_type_mod.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_sfv src/local/.fypp/arpifs/module/surface_views_diagnostic_module.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_sfv src/local/.fypp/arpifs/module/surface_views_prognostic_module.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_sfc src/local/.fypp/arpifs/module/surface_variables_mod.F90

generateStructureMethods.pl \
 --field-api --field-api-class info_sfc src/local/.fypp/arpifs/module/mf_phys_surface_type_mod.F90

./scripts/linkTypes.pl


