
cmake_minimum_required ( VERSION 3.0 )

project ( babelfishpg_common C )

add_library ( ${PROJECT_NAME} SHARED 
    src/babelfishpg_common.c
    src/varchar.c
    src/bit.c
    src/instr.c
    src/typecode.c
    src/numeric.c
    src/varbinary.c
    src/uniqueidentifier.c
    src/datetime.c
    src/datetime2.c
    src/smalldatetime.c
    src/datetimeoffset.c
    src/sqlvariant.c
    src/coerce.c
    src/collation.c
    src/encoding/encoding_utils.c
    src/encoding/mb/conv.c
    src/encoding/mb/conversion_procs/utf8_and_big5/utf8_and_big5.c
    src/encoding/mb/conversion_procs/utf8_and_gbk/utf8_and_gbk.c
    src/encoding/mb/conversion_procs/utf8_and_sjis/utf8_and_sjis.c
    src/encoding/mb/conversion_procs/utf8_and_uhc/utf8_and_uhc.c
    src/encoding/mb/conversion_procs/utf8_and_win/utf8_and_win.c )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_LIST_DIR} )

set ( PG_DIST C:/projects/postgres/dist )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server/port/win32_msvc )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server/port/win32 )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include )

set ( PG_SRC C:/projects/postgres/postgresql_modified_for_babelfish )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_SRC} )

target_include_directories ( ${PROJECT_NAME} PRIVATE C:/projects/postgres/icu_bin/include )

target_link_libraries ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/lib/postgres.lib )
target_link_libraries ( ${PROJECT_NAME} PRIVATE
    C:/projects/postgres/icu_bin/lib64/icuin.lib 
    C:/projects/postgres/icu_bin/lib64/icuuc.lib 
    )

install ( TARGETS ${PROJECT_NAME}
    DESTINATION ${PG_DIST}/lib )