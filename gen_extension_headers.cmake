option(GLSLANG_INTRINSIC_HEADER_DIR "input dir")
option(GLSLANG_INTRINSIC_H "output file")

if (NOT GLSLANG_INTRINSIC_HEADER_DIR)
	message(FATAL_ERROR "-DGLSLANG_INTRINSIC_HEADER_DIR option is required")
endif()
if (NOT GLSLANG_INTRINSIC_H)
	message(FATAL_ERROR "-DGLSLANG_INTRINSIC_H option is required")
endif()

#
# CMake version of gen_extension_headers.py
#
file(GLOB glsl_files ${GLSLANG_INTRINSIC_HEADER_DIR}/*.glsl)
# Write commit ID to output header file
file(WRITE ${GLSLANG_INTRINSIC_H} [[
/***************************************************************************
 *
 * Copyright (c) 2015-2021 The Khronos Group Inc.
 * Copyright (c) 2015-2021 Valve Corporation
 * Copyright (c) 2015-2021 LunarG, Inc.
 * Copyright (c) 2015-2021 Google Inc.
 * Copyright (c) 2021 Advanced Micro Devices, Inc.All rights reserved.
 *
 ****************************************************************************/
#pragma once

#ifndef _INTRINSIC_EXTENSION_HEADER_H_
#define _INTRINSIC_EXTENSION_HEADER_H_

]])

set(symbol_name_list)

foreach(i ${glsl_files})
	message(STATUS "Processing ${i}")
	file(READ ${i} glsl_contents)
	cmake_path(GET i FILENAME filename)
	string(REGEX MATCH "^[^.]+" symbol_name ${filename})
	list(APPEND symbol_name_list ${symbol_name})
	file(APPEND ${GLSLANG_INTRINSIC_H} "std::string ${symbol_name}_GLSL = R\"(\n${glsl_contents}\n)\"")
	file(APPEND ${GLSLANG_INTRINSIC_H} [[;

]])
endforeach()

file(APPEND ${GLSLANG_INTRINSIC_H} [[
std::string getIntrinsic(const char* const* shaders, int n) {
	std::string shaderString = "";
	for (int i = 0; i < n; i++) {
]])
		foreach(symbol_name ${symbol_name_list})
			file(APPEND ${GLSLANG_INTRINSIC_H} "\t\tif (strstr(shaders[i], \"${symbol_name}\") != nullptr) {\n")
			file(APPEND ${GLSLANG_INTRINSIC_H} "\t\t    shaderString.append(${symbol_name}_GLSL);\n")
			file(APPEND ${GLSLANG_INTRINSIC_H} "\t\t}")
		endforeach()

file(APPEND ${GLSLANG_INTRINSIC_H} [[	
	}
	return shaderString;
}

#endif
]]
)
