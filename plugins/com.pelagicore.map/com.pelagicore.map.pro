TEMPLATE = lib
TARGET  = mapshelperplugin
QT += quick
CONFIG += qt plugin c++11

uri = com.pelagicore.map
load(qmlplugin)

SOURCES += \
    plugin.cpp \
    mapshelper.cpp \

HEADERS += \
    mapshelper.h \
