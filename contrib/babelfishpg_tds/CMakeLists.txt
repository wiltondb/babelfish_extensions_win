
cmake_minimum_required ( VERSION 3.0 )

project ( babelfishpg_tds C )

execute_process ( COMMAND perl
    ${CMAKE_CURRENT_LIST_DIR}/generate_error_mapping.pl
    ${CMAKE_CURRENT_LIST_DIR}/error_mapping.txt
    OUTPUT_FILE ${CMAKE_CURRENT_LIST_DIR}/src/include/error_mapping.h )

add_library ( ${PROJECT_NAME} SHARED 
    src/backend/fault_injection/fault_injection.c 
    src/backend/fault_injection/fault_injection_tests.c 

    src/backend/tds/err_handler.c
    src/backend/tds/guc.c
    src/backend/tds/tdsbulkload.c
    src/backend/tds/tds.c
    src/backend/tds/tdscomm.c
    src/backend/tds/tdslogin.c
    src/backend/tds/tdsprotocol.c
    src/backend/tds/tdsresponse.c
    src/backend/tds/tdsrpc.c
    src/backend/tds/tdssecure.c
    src/backend/tds/tds-secure-openssl.c
    src/backend/tds/tdssqlbatch.c
    src/backend/tds/tds_srv.c
    src/backend/tds/tdstimestamp.c
    src/backend/tds/tdstypeio.c
    src/backend/tds/tdsutils.c
    src/backend/tds/tdsxact.c

    src/backend/utils/adt/numeric.c
    src/backend/utils/adt/varchar.c
    src/backend/utils/adt/xml.c )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR} )

set ( PG_DIST C:/projects/postgres/dist )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server/port/win32_msvc )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server/port/win32 )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include )
target_include_directories ( ${PROJECT_NAME} PRIVATE C:/projects/postgres/int128_win )

set ( PG_SRC C:/projects/postgres/postgresql_modified_for_babelfish )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_SRC} )

set ( LIBXML_DIST C:/projects/postgres/libxml2/dist )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${LIBXML_DIST}/include/libxml2 )
target_include_directories ( ${PROJECT_NAME} PRIVATE C:/projects/postgres/babelfish_extensions/contrib/babelfishpg_tsql )

target_compile_definitions ( ${PROJECT_NAME} PRIVATE USE_LIBXML )

target_link_libraries ( ${PROJECT_NAME} PRIVATE
        ${PG_DIST}/lib/postgres.lib
        ${LIBXML_DIST}/lib/libxml2.lib
        Ws2_32 )

install ( TARGETS ${PROJECT_NAME}
    DESTINATION ${PG_DIST}/lib )