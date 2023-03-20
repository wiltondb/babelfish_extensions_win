
cmake_minimum_required ( VERSION 3.0 )

project ( babelfishpg_money C )

add_library ( ${PROJECT_NAME} SHARED fixeddecimal.c )

set ( PG_DIST C:/projects/postgres/dist )

target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server/port/win32_msvc )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server/port/win32 )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include/server )
target_include_directories ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/include )
target_include_directories ( ${PROJECT_NAME} PRIVATE C:/projects/postgres/int128_win )

target_link_libraries ( ${PROJECT_NAME} PRIVATE ${PG_DIST}/lib/postgres.lib )