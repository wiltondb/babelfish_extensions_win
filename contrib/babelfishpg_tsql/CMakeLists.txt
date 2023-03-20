
cmake_minimum_required ( VERSION 3.0 )

project ( babelfishpg_tsql C CXX )
set(CMAKE_CXX_STANDARD 14)

set ( PG_SRC C:/projects/postgres/postgresql_modified_for_babelfish )

execute_process ( COMMAND perl
    -I ${PG_SRC}/src/tools 
    ${PG_SRC}/src/tools/gen_keywordlist.pl
    --output src/backend_parser
    --varname pgtsql_ScanKeywords
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/kwlist.h
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} )

execute_process ( COMMAND C:/projects/postgres/tools/msys/bin/bison.exe
    -d -o pl_gram.c pl_gram.y
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src )

execute_process ( COMMAND perl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/include.pl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser
    gram.y
    INPUT_FILE ${PG_SRC}/src/backend/parser/gram.y
    OUTPUT_FILE ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/gram-backend.y )

execute_process ( COMMAND C:/projects/postgres/tools/msys/bin/bison.exe
    -d -o gram-backend.c gram-backend.y
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser )

execute_process ( COMMAND perl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/include.pl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser
    scan.l
    INPUT_FILE ${PG_SRC}/src/backend/parser/scan.l
    OUTPUT_FILE ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/scan-backend.l )

execute_process ( COMMAND C:/projects/postgres/tools/msys/bin/flex.exe
    -b -CF -p -p -o scan-backend.c scan-backend.l 
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser )

execute_process ( COMMAND perl
    ${PG_SRC}/src/tools/fix-old-flex-code.pl
    ${CMAKE_CURRENT_LIST_DIR}/src/backend_parser/scan-backend.c )

execute_process ( COMMAND perl
    -I ${PG_SRC}/src/tools 
    ${PG_SRC}/src/tools/gen_keywordlist.pl
    --varname ReservedPLKeywords
    ${CMAKE_CURRENT_LIST_DIR}/src/pl_reserved_kwlist.h
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} )
 
execute_process ( COMMAND perl
    -I ${PG_SRC}/src/tools 
    ${PG_SRC}/src/tools/gen_keywordlist.pl
    --varname UnreservedPLKeywords
    ${CMAKE_CURRENT_LIST_DIR}/src/pl_unreserved_kwlist.h
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR} )

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
    src/forxml.c
    src/pltsql_identity.c
    src/collationproperty.c
    src/rolecmds.c
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
    src/forjson.c 
    src/pltsql_bulkcopy.c
    src/win_utils.c )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR} )

set ( PG_DIST C:/projects/postgres/dist )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server/port/win32_msvc )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server/port/win32 )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_SRC} )

target_include_directories ( ${PROJECT_NAME} PRIVATE C:/projects/postgres/antlr4/runtime/Cpp/runtime/src )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/antlr/build/antlr4cpp_generated_src )

target_compile_definitions ( ${PROJECT_NAME} PRIVATE ANTLR4CPP_STATIC )

target_link_libraries ( ${PROJECT_NAME} PRIVATE
        ${PG_DIST}/lib/postgres.lib
        C:/projects/postgres/babelfish_extensions/contrib/babelfishpg_common/build/Debug/babelfishpg_common.lib
        C:/projects/postgres/babelfish_extensions/contrib/babelfishpg_tsql/antlr/build/Debug/antlr_tsql.lib 
        C:/projects/postgres/antlr4/runtime/Cpp/dist/Debug/antlr4-runtime-static.lib )