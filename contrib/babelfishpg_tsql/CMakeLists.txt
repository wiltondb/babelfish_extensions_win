# Copyright 2023 alex@staticlibs.net
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.crg/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required ( VERSION 3.19 )

project ( babelfishpg_tsql C CXX )

set ( PGTSQL_MAJOR_VERSION 3 )
set ( PGTSQL_MINOR_VERSION 2 )
set ( PGTSQL_MICRO_VERSION 0 )
set ( EXTVERSION ${PGTSQL_MAJOR_VERSION}.${PGTSQL_MINOR_VERSION}.${PGTSQL_MICRO_VERSION} )
set ( MODULEPATH $libdir/${PROJECT_NAME}-${PGTSQL_MAJOR_VERSION} )

if ( NOT DEFINED ENV{PGWIN_DEPS_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_DEPS_DIR' (pointing to the pgwin_deps installation directory) must be specified" )
endif ()
if ( NOT DEFINED ENV{PGWIN_INSTALL_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_INSTALL_DIR' (pointing to the postgresql_modified_for_babelfish installation directory) must be specified" )
endif ()
if ( NOT DEFINED ENV{PGWIN_SRC_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_SRC_DIR' (pointing to the postgresql_modified_for_babelfish source directory) must be specified" )
endif ()

message ( STATUS "Generating code" )

execute_process ( COMMAND perl
    -I $ENV{PGWIN_SRC_DIR}/src/tools 
    $ENV{PGWIN_SRC_DIR}/src/tools/gen_keywordlist.pl
    --output src/backend_parser
    --varname pgtsql_ScanKeywords
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/kwlist.h
    COMMAND_ERROR_IS_FATAL ANY
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} )

execute_process ( COMMAND $ENV{PGWIN_DEPS_DIR}/bison/bison.exe
    --warnings=none --no-lines -d -o pl_gram.c pl_gram.y
    COMMAND_ERROR_IS_FATAL ANY
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src )

execute_process ( COMMAND perl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/include.pl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser
    gram.y
    INPUT_FILE $ENV{PGWIN_SRC_DIR}/src/backend/parser/gram.y
    OUTPUT_FILE ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/gram-backend.y
    COMMAND_ERROR_IS_FATAL ANY )

execute_process ( COMMAND $ENV{PGWIN_DEPS_DIR}/bison/bison.exe
    --warnings=none --no-lines -d -o gram-backend.c gram-backend.y
    COMMAND_ERROR_IS_FATAL ANY
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser )

execute_process ( COMMAND perl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/include.pl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser
    scan.l
    INPUT_FILE $ENV{PGWIN_SRC_DIR}/src/backend/parser/scan.l
    OUTPUT_FILE ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/scan-backend.l
    COMMAND_ERROR_IS_FATAL ANY )

execute_process ( COMMAND $ENV{PGWIN_DEPS_DIR}/bison/flex.exe
    -w -L -b -CF -p -p -o scan-backend.c scan-backend.l 
    COMMAND_ERROR_IS_FATAL ANY
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser )

execute_process ( COMMAND perl
    $ENV{PGWIN_SRC_DIR}/src/tools/fix-old-flex-code.pl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/scan-backend.c 
    COMMAND_ERROR_IS_FATAL ANY )

execute_process ( COMMAND perl
    -I $ENV{PGWIN_SRC_DIR}/src/tools 
    $ENV{PGWIN_SRC_DIR}/src/tools/gen_keywordlist.pl
    --varname ReservedPLKeywords
    ${CMAKE_CURRENT_LIST_DIR}/src/pl_reserved_kwlist.h
    COMMAND_ERROR_IS_FATAL ANY
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} )
 
execute_process ( COMMAND perl
    -I $ENV{PGWIN_SRC_DIR}/src/tools 
    $ENV{PGWIN_SRC_DIR}/src/tools/gen_keywordlist.pl
    --varname UnreservedPLKeywords
    ${CMAKE_CURRENT_LIST_DIR}/src/pl_unreserved_kwlist.h
    COMMAND_ERROR_IS_FATAL ANY
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} )

set(CMAKE_CXX_STANDARD 14)

add_library ( ${PROJECT_NAME} SHARED 
    src/pl_gram.c
    src/pl_handler.c
    src/pl_comp.c
    src/pl_exec.c
    src/pl_funcs.c
    src/pl_scanner.c
    src/pl_comp-2.c
    src/pl_explain.c
    src/properties.c
    src/databasepropertyex.c
    src/plan_inval.c
    src/procedures.c
    src/cursor.c
    src/applock.c
    src/pltsql_coerce.c
    runtime/functions.c
    src/err_handler.c
    src/pltsql_function_probin_handler.c
    src/pltsql_utils.c
    src/tablecmds.c
    src/stmt_walker.c
    src/codegen.c
    src/dynavec.c
    src/dynastack.c
    src/analyzer.c
    src/prepare.c
    src/compile_context.c
    src/collation.c
    src/string.c
    src/format.c
    src/pltsql_identity.c
    src/collationproperty.c
    src/rolecmds.c
    src/linked_servers.c
    src/backend_parser/keywords.c
    src/backend_parser/parser.c
    src/backend_parser/scan-backend.c
    src/backend_parser/gram-backend.c
    src/backend_parser/gram_hook.c
    src/dbcmds.c
    src/session.c
    src/guc.c
    src/catalog.c
    src/schemacmds.c
    src/hooks.c
    src/tsqlNodes.c
    src/tsqlHandler.c
    src/tsqlUnsupportedFeatureHandler.cpp
    src/tsqlIface.cpp
    src/special_keywords.c
    src/multidb.c
    src/json_funcs.c
    src/pltsql_ruleutils.c
    src/tsql_for/tsql_for.c
    src/tsql_for/forjson.c
    src/tsql_for/forjson_old.c
    src/tsql_for/forxml.c
    src/tsql_for/forxml_old.c
    src/tsql_analyze.c
    src/pltsql_bulkcopy.c
    src/tsql_win.c
    src/tsql_winx.cpp
    
    src/rolecmds.h
    src/linked_servers.h
    src/err_handler.h
    src/hooks.h
    src/iterative_exec.h
    src/datatype_info.h
    src/multidb.h
    src/pl_explain.h
    src/tsql_analyze.h
    src/pltsql.h
    src/plerrcodes.h
    src/schemacmds.h
    src/pltsql-2.h
    src/session.h
    src/collation.h
    src/pl_funcs-2.h
    src/babelfish_version.h
    src/pl_unreserved_kwlist.h
    src/dynastack.h
    src/pltsql_bulkcopy.h
    src/stmt_walker.h
    src/dbcmds.h
    src/dynavec.h
    src/compile_context.h
    src/catalog.h
    src/analyzer.h
    src/tsqlNodes.h
    src/format.h
    src/codegen.h
    src/pltsql_instr.h
    src/backend_parser/kwlist.h
    src/backend_parser/scan-tsql-prologue.l.h
    src/backend_parser/gramparse.h
    src/backend_parser/scan-tsql-prologue-top.l.h
    src/backend_parser/scanner.h
    src/backend_parser/gram-tsql-prologue.y.h
    src/guc.h
    src/pl_reserved_kwlist.h
    src/tsql_for/tsql_for.h
    src/tsql_win.h

    ${PROJECT_NAME}.def )

target_include_directories ( ${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}
    #${CMAKE_CURRENT_LIST_DIR}/../babelfishpg_tsql
    ${CMAKE_CURRENT_LIST_DIR}/antlr/build/antlr4cpp_generated_src
    $ENV{PGWIN_INSTALL_DIR}/include/server/port/win32_msvc 
    $ENV{PGWIN_INSTALL_DIR}/include/server/port/win32
    $ENV{PGWIN_INSTALL_DIR}/include/server
    $ENV{PGWIN_INSTALL_DIR}/include
    $ENV{PGWIN_DEPS_DIR}/int128
    $ENV{PGWIN_DEPS_DIR}/icu/include
    $ENV{PGWIN_DEPS_DIR}/openssl/include
    #$ENV{PGWIN_DEPS_DIR}/xml/include/libxml2
    $ENV{PGWIN_DEPS_DIR}/antlr4_cpp_runtime/include/antlr4-runtime
    $ENV{PGWIN_DEPS_DIR}/utf8cpp/include/utf8cpp
    $ENV{PGWIN_SRC_DIR} )

target_compile_options ( ${PROJECT_NAME} PRIVATE
    /wd4267
    /wd4996 )

target_compile_definitions ( ${PROJECT_NAME} PRIVATE
    _CRT_SECURE_NO_WARNINGS
    ANTLR4CPP_STATIC
    USE_UTF8_INSTEAD_OF_CODECVT
    FAULT_INJECTOR
    BABELFISH_EXTENSION_BUILD )

target_link_libraries ( ${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/antlr/build/dist/babelfishpg_tsql_antlr.lib
    $ENV{PGWIN_INSTALL_DIR}/lib/postgres.lib
    $ENV{PGWIN_DEPS_DIR}/icu/lib64/icuuc.lib
    $ENV{PGWIN_DEPS_DIR}/icu/lib64/icuin.lib
    #$ENV{PGWIN_DEPS_DIR}/xml/lib/libxml2.lib
    $ENV{PGWIN_DEPS_DIR}/openssl/lib/libssl.lib
    $ENV{PGWIN_DEPS_DIR}/openssl/lib/libcrypto.lib
    $ENV{PGWIN_DEPS_DIR}/antlr4_cpp_runtime/lib/antlr4-runtime-static.lib
    shlwapi
    ws2_32 )

configure_file ( ${PROJECT_NAME}.control.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.control 
    @ONLY 
    NEWLINE_STYLE LF )

file ( READ sql/${PROJECT_NAME}.prologue.sql PROLOGUE_SQL )
file ( READ sql/collation.sql COLLATION_SQL )
file ( READ sql/datatype.sql DATATYPE_SQL )
file ( READ sql/datatype_string_operators.sql DATATYPE_STRING_OPERATORS_SQL )
file ( READ sql/sys.sql SYS_SQL )
file ( READ sql/sys_languages.sql SYS_LANGUAGES_SQL )
file ( READ sql/sys_babelfish_configurations.sql SYS_BABELFISH_CONFIGURATION_SQL )
file ( READ sql/sys_function_helpers.sql SYS_FUNCTION_HELPERS_SQL )
file ( READ sql/sys_functions.sql SYS_FUNCTIONS_SQL )
file ( READ sql/sys_cast.sql SYS_CAST_SQL )
file ( READ sql/coerce.sql COERCE_SQL )
file ( READ sql/object_definition_tsql.sql OBJECT_DEFINITION_TSQL_SQL )
file ( READ sql/ownership.sql OWNERSHIP_SQL )
file ( READ sql/sys_views.sql SYS_VIEWS_SQL )
file ( READ sql/information_schema_tsql.sql INFORMATION_SCHEMA_TSQL_SQL )
file ( READ sql/sys_procedures.sql SYS_PROCEDURES_SQL )
file ( READ sql/import_export_compatibility.sql IMPORT_EXPORT_COMPATIBILITY_SQL )
file ( READ sql/babelfishpg_tsql.sql BABELFISHPG_TSQL_SQL )
file ( READ sql/${PROJECT_NAME}.epilogue.sql EPILOGUE_SQL )
string ( CONCAT ${PROJECT_NAME}_SQL
    "${PROLOGUE_SQL}"
    "${COLLATION_SQL}"
    "${DATATYPE_SQL}"
    "${DATATYPE_STRING_OPERATORS_SQL}"
    "${SYS_SQL}"
    "${SYS_LANGUAGES_SQL}"
    "${SYS_BABELFISH_CONFIGURATION_SQL}"
    "${SYS_FUNCTION_HELPERS_SQL}"
    "${SYS_FUNCTIONS_SQL}"
    "${SYS_CAST_SQL}"
    "${COERCE_SQL}"
    "${OBJECT_DEFINITION_TSQL_SQL}"
    "${OWNERSHIP_SQL}"
    "${SYS_VIEWS_SQL}"
    "${INFORMATION_SCHEMA_TSQL_SQL}"
    "${SYS_PROCEDURES_SQL}"
    "${IMPORT_EXPORT_COMPATIBILITY_SQL}"
    "${BABELFISHPG_TSQL_SQL}"
    "${EPILOGUE_SQL}" )
file ( GENERATE
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}--${EXTVERSION}.sql
    CONTENT "${${PROJECT_NAME}_SQL}"
    NEWLINE_STYLE LF )

install ( TARGETS ${PROJECT_NAME}
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/lib )

install ( FILES
    sql/upgrades/${PROJECT_NAME}--1.0.0--1.1.0.sql
    sql/upgrades/${PROJECT_NAME}--1.1.0--1.2.0.sql
    sql/upgrades/${PROJECT_NAME}--1.2.0--1.2.1.sql
    sql/upgrades/${PROJECT_NAME}--1.2.1--2.0.0.sql
    sql/upgrades/${PROJECT_NAME}--2.0.0--2.1.0.sql
    sql/upgrades/${PROJECT_NAME}--2.1.0--2.2.0.sql
    sql/upgrades/${PROJECT_NAME}--2.2.0--2.3.0.sql
    sql/upgrades/${PROJECT_NAME}--2.3.0--2.4.0.sql
    sql/upgrades/${PROJECT_NAME}--2.3.0--3.0.0.sql
    sql/upgrades/${PROJECT_NAME}--2.4.0--3.0.0.sql
    sql/upgrades/${PROJECT_NAME}--3.0.0--3.1.0.sql
    sql/upgrades/${PROJECT_NAME}--3.1.0--3.2.0.sql
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}--${EXTVERSION}.sql
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.control
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/share/extension )

