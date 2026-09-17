cmake_minimum_required(VERSION 3.21)

project(ControlCenter LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick QuickControls2 Svg)

qt_standard_project_setup(REQUIRES 6.5)

qt_policy(SET QTP0004 NEW)

set(CLEVO_SDK_BUILD_SHARED OFF CACHE BOOL "Build ClevoCommunitySDK as a DLL")
add_subdirectory(external/clevo-community-sdk)

qt_add_executable(ControlCenter WIN32
        src/main.cpp
        src/WinChrome.h
        src/WinChrome.cpp
        src/Theme.h
        src/TrayController.h
        src/TrayController.cpp
        src/services/ServiceSupport.h
        src/services/DeviceService.h
        src/services/DeviceService.cpp
        src/services/PowerService.h
        src/services/PowerService.cpp
        src/services/KeyboardService.h
        src/services/KeyboardService.cpp
        src/services/FanService.h
        src/services/FanService.cpp
)

if(WIN32)
    target_sources(ControlCenter PRIVATE resources/app.rc)
    # windres dependencies are not scanned, so a regenerated icon would
    # otherwise never make it into the executable.
    set_property(SOURCE resources/app.rc PROPERTY OBJECT_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/app_icon.ico")
endif()

qt_add_qml_module(ControlCenter
    URI ControlCenter
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/components/TitleBar.qml
        qml/components/CaptionButton.qml
        qml/components/NavRail.qml
        qml/components/NavItem.qml
        qml/components/ToggleSwitch.qml
        qml/components/ModeCard.qml
        qml/components/SectionPanel.qml
        qml/components/GradientSlider.qml
        qml/components/ColorPickerSV.qml
        qml/components/HueSlider.qml
        qml/components/FanCurveChart.qml
        qml/components/ResizeBorders.qml
        qml/components/NumberField.qml
        qml/components/AcrylicScrollBar.qml
        qml/components/icons/IconPerformance.qml
        qml/components/icons/IconKeyboard.qml
        qml/components/icons/IconFan.qml
        qml/components/icons/IconEnthusiasts.qml
        qml/components/icons/IconSilent.qml
        qml/components/icons/IconPowerSaver.qml
        qml/components/icons/IconEntertainment.qml
        qml/components/icons/IconFullPerformance.qml
        qml/components/icons/IconChevronDown.qml
        qml/pages/PerformanceModesPage.qml
        qml/pages/KeyboardColorPage.qml
        qml/pages/FanControlPage.qml
        qml/pages/EnthusiastsPage.qml
    RESOURCES
        resources/app_icon.svg
)

target_link_libraries(ControlCenter
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Svg
        ClevoCommunitySDK::ClevoCommunitySDK
)

if(WIN32)
    target_link_libraries(ControlCenter PRIVATE dwmapi)
endif()

clevo_sdk_deploy_runtime(ControlCenter INSTALL_DESTINATION .)

qt_import_qml_plugins(ControlCenter)

# Copy the Qt runtime (and the MinGW runtime) next to the freshly built
# executable so it starts from CLion or Explorer without a Qt-aware PATH.
option(CONTROLCENTER_DEPLOY_QT_RUNTIME "Run windeployqt after each build" ON)

if(WIN32 AND CONTROLCENTER_DEPLOY_QT_RUNTIME)
    find_program(WINDEPLOYQT_EXECUTABLE windeployqt
        HINTS "${QT6_INSTALL_PREFIX}/${QT6_INSTALL_BINS}"
    )
    if(WINDEPLOYQT_EXECUTABLE)
        add_custom_command(TARGET ControlCenter POST_BUILD
            COMMAND "${WINDEPLOYQT_EXECUTABLE}"
                    --qmldir "${CMAKE_CURRENT_SOURCE_DIR}/qml"
                    --no-translations
                    --compiler-runtime
                    "$<TARGET_FILE:ControlCenter>"
            COMMENT "Deploying the Qt runtime next to ControlCenter.exe"
            VERBATIM
        )
    else()
        message(WARNING "windeployqt not found - ControlCenter.exe will need Qt on PATH to run.")
    endif()
endif()

install(TARGETS ControlCenter
    BUNDLE DESTINATION .
    RUNTIME DESTINATION .
)

qt_generate_deploy_qml_app_script(
    TARGET ControlCenter
    OUTPUT_SCRIPT deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
)
install(SCRIPT ${deploy_script})
