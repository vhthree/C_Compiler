cmake_minimum_required(VERSION 3.16) # 指定所需的最低CMake版本
project(Compilerlab2) # 定义项目名称为Compilerlab2

# 尝试找到Bison

# 指定C++标准
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)
# 添加编译选项，对于非标准的代码发出警告
# add_compile_options(-pedantic)
add_compile_options(-pedantic -Os -fno-rtti -fno-exceptions)  # 添加优化选项

# 可选的，如果你想启用地址消毒器来帮助找到内存错误，可以取消以下两行的注释
# add_compile_options(-fsanitize=address)
# add_link_options(-fsanitize=address)
# 查找必需的包
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# 生成词法分析器代码
FLEX_TARGET(MyLexer lexical.l ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.cpp)

# 生成语法分析器代码
BISON_TARGET(MyParser syntax.y ${CMAKE_CURRENT_BINARY_DIR}/syntax.tab.cpp COMPILE_FLAGS "-d -v")

# 为 Flex 和 Bison 的输出创建一个静态库
add_library(compilerlab_lib STATIC ${BISON_MyParser_OUTPUTS} ${FLEX_MyLexer_OUTPUTS})

# 确保 Flex 和 Bison 的 header 文件可以被找到
target_include_directories(compilerlab_lib PUBLIC ${CMAKE_CURRENT_BINARY_DIR})

# 指定 main.cpp 和链接到上面创建的库
add_executable(Compilerlab2 zzy.cpp)
target_link_libraries(Compilerlab2 compilerlab_lib)


# 设置目标的C++标准为C++14
target_compile_features(Compilerlab2 PRIVATE cxx_std_14)
# 添加自定义命令来剥离调试信息
add_custom_command(TARGET compilerlab_lib POST_BUILD
                   COMMAND ${CMAKE_STRIP} --strip-debug $<TARGET_FILE:compilerlab_lib>)