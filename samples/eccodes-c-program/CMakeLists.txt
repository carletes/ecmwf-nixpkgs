cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

project( eccodes-c-program VERSION 0.0.1 LANGUAGES C )

include( ecbuild_system NO_POLICY_SCOPE )

ecbuild_declare_project()

ecbuild_requires_macro_version( 2.0 )

ecbuild_find_package( NAME eccodes VERSION 2.27.0 REQUIRED )

ecbuild_add_executable(
    TARGET   grib_print_data
    INCLUDES ${ECCODES_INCLUDE_DIRS}
    SOURCES  grib_print_data.c
    LIBS     eccodes
)

ecbuild_install_project( NAME ${PROJECT_NAME} )

ecbuild_print_summary()
