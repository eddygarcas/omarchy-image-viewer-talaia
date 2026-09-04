cmake_minimum_required(VERSION 3.21)
project(image-viewer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

set(BACKEND_DIR ${CMAKE_SOURCE_DIR}/../backend)
set(BACKEND_LIB ${BACKEND_DIR}/zig-out/lib/libimgbackend.so)
set(BACKEND_INCLUDE ${BACKEND_DIR}/include)

if(NOT EXISTS ${BACKEND_LIB})
    message(FATAL_ERROR "Backend not built yet: ${BACKEND_LIB} missing. Run `zig build` in ${BACKEND_DIR} first.")
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick)

qt_standard_project_setup(REQUIRES 6.5)

# `pragma Singleton` alone isn't reliably picked up by qt_add_qml_module's
# automatic qmldir generation; without this, Theme.qml gets registered as a
# plain type, and every `Theme.foo` reference elsewhere silently evaluates to
# undefined (no build or runtime warning) instead of erroring.
set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_executable(image-viewer
    src/main.cpp
    src/ImageBackend.cpp
    src/ImageBackend.h
    src/ImageProvider.cpp
    src/ImageProvider.h
    src/FolderModel.cpp
    src/FolderModel.h
    src/ThemeReader.cpp
    src/ThemeReader.h
)

qt_add_qml_module(image-viewer
    URI ImageViewer
    VERSION 1.0
    QML_FILES
        qml/main.qml
        qml/ImageView.qml
        qml/EditToolbar.qml
        qml/SlideshowOverlay.qml
        qml/RoundedButton.qml
        qml/RoundedToolButton.qml
        qml/ChainToggle.qml
        qml/Theme.qml
        qml/Glyph.qml
        qml/Icons.js
)

qt_add_resources(image-viewer "icon"
    PREFIX "/"
    FILES resources/icons/talaia.svg
)

target_include_directories(image-viewer PRIVATE ${BACKEND_INCLUDE})
target_link_libraries(image-viewer PRIVATE Qt6::Core Qt6::Gui Qt6::Quick ${BACKEND_LIB})

set_target_properties(image-viewer PROPERTIES
    BUILD_RPATH ${BACKEND_DIR}/zig-out/lib
    INSTALL_RPATH ${BACKEND_DIR}/zig-out/lib
)
