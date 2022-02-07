TARGET = $$qtLibraryTarget(RemoteSettings)
TEMPLATE = lib
CONFIG += ivigenerator
DESTDIR = $$LIB_DESTDIR

QT_FOR_CONFIG += ivicore
!qtConfig(ivigenerator): error("No ivigenerator available")

macos: QMAKE_SONAME_PREFIX = @rpath

include($$SOURCE_DIR/config.pri)

DEFINES += QT_BUILD_SETTINGS_LIB
QT += ivicore ivicore-private qml quick

QFACE_SOURCES = ../settings.qface

DEPENDPATH += $$OUT_PWD/../frontend

target.path = $$INSTALL_PREFIX/neptune3/lib
win32:target.path = $$INSTALL_PREFIX/neptune3/
INSTALLS += target
