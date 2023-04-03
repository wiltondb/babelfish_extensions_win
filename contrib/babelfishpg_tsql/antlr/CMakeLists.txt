# minimum required CMAKE version
CMAKE_MINIMUM_REQUIRED(VERSION 3.7 FATAL_ERROR)

project ( babelfishpg_tsql_antlr C CXX )

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-dir)

if ( NOT DEFINED ENV{PGWIN_DEPS_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_DEPS_DIR' (pointing to the pgwin_deps installation directory) must be specified" )
endif ()
if ( NOT DEFINED ENV{ANTLR4_JAVA_BIN} )
    message( FATAL_ERROR "Environment variable 'ANTLR4_JAVA_BIN' (pointing to the java.exe) must be specified" )
endif ()

# compiler must be 11 or 14
set(CMAKE_CXX_STANDARD 14)

# set variable pointing to the antlr tool that supports C++
# this is not required if the jar file can be found under PATH environment
set(ANTLR_EXECUTABLE ${PROJECT_SOURCE_DIR}/thirdparty/antlr/antlr-4.9.3-complete.jar)
# add macros to generate ANTLR Cpp code from grammar
find_package(ANTLR REQUIRED)

antlr_target(SampleGrammarLexer TSqlLexer.g4 LEXER)
antlr_target(SampleGrammarParser TSqlParser.g4 PARSER LISTENER VISITOR
			 DEPENDS_ANTLR SampleGrammarLexer
			 COMPILE_FLAGS -lib ${ANTLR_SampleGrammarLexer_OUTPUT_DIR})

add_custom_target ( add_u8_prefix_to_fix_C4566
        COMMAND perl ${CMAKE_CURRENT_LIST_DIR}/fix_C4566.pl
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/antlr4cpp_generated_src
        COMMENT "Fixing C4566"
        DEPENDS ${ANTLR_SampleGrammarLexer_CXX_OUTPUTS} ${ANTLR_SampleGrammarParser_CXX_OUTPUTS} )

add_library ( ${PROJECT_NAME} STATIC
    ${ANTLR_SampleGrammarLexer_CXX_OUTPUTS}
    ${ANTLR_SampleGrammarParser_CXX_OUTPUTS})

add_dependencies ( ${PROJECT_NAME} add_u8_prefix_to_fix_C4566 )

target_include_directories ( ${PROJECT_NAME} PRIVATE
    $ENV{PGWIN_DEPS_DIR}/antlr4_cpp_runtime/include/antlr4-runtime
    $ENV{PGWIN_DEPS_DIR}/utf8cpp/include/utf8cpp
    ${ANTLR_SampleGrammarLexer_OUTPUT_DIR}
    ${ANTLR_SampleGrammarParser_OUTPUT_DIR} )

target_compile_options ( ${PROJECT_NAME} PRIVATE
    /bigobj )

target_compile_definitions ( ${PROJECT_NAME} PRIVATE
    ANTLR4CPP_STATIC
    USE_UTF8_INSTEAD_OF_CODECVT )
