/****************************************************************************
**
** Copyright (C) 2019 Luxoft Sweden AB
** Copyright (C) 2018 Pelagicore AG
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Neptune 3 IVI UI.
**
** $QT_BEGIN_LICENSE:GPL-QTAS$
** Commercial License Usage
** Licensees holding valid commercial Qt Automotive Suite licenses may use
** this file in accordance with the commercial license agreement provided
** with the Software or, alternatively, in accordance with the terms
** contained in a written agreement between you and The Qt Company.  For
** licensing terms and conditions see https://www.qt.io/terms-conditions.
** For further information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
** SPDX-License-Identifier: GPL-3.0
**
****************************************************************************/
#include "WidgetListModel.h"

#include <QDebug>

int WidgetListModel::rowCount(const QModelIndex &/*parent*/) const
{
    return m_list.count();
}

QVariant WidgetListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() >= 0 && index.row() < m_list.count()) {
        const ListItem &listItem = m_list.at(index.row());
        if (role == RoleAppInfo) {
            return QVariant::fromValue(listItem.appInfo);
        } else if (role == RoleRowIndex) {
            return QVariant::fromValue(listItem.rowIndex);
        }
    }
    return QVariant();
}

QAbstractItemModel *WidgetListModel::applicationModel() const
{
    return m_applicationModel;
}

void WidgetListModel::setApplicationModel(QAbstractItemModel *appModel)
{
    if (appModel == m_applicationModel) {
        return;
    }
    setPopulating(true);

    disconnect(appModel, 0, this, 0);
    m_list.clear();

    m_applicationModel = appModel;
    emit applicationModelChanged();

    if (!appModel) {
        return;
    }

    if (appModel->rowCount() > 0) {
        trackRowsFromApplicationModel(0, appModel->rowCount() - 1);
    }
    setPopulating(false);

    connect(appModel, &QAbstractItemModel::rowsInserted, this,
            [this](const QModelIndex & /*parent*/, int first, int last)
            {
                this->trackRowsFromApplicationModel(first, last);
            });

    connect(appModel, &QAbstractItemModel::rowsAboutToBeRemoved, this,
            [this](const QModelIndex & /*parent*/, int first, int last)
            {
                for (int i = first; i <= last; ++i) {
                    auto *appInfo = m_appModelIndexToAppInfo[i];
                    detachApplicationInfo(appInfo);
                    remove(indexFromAppInfo(appInfo));
                    disconnect(appInfo, 0, this, 0);

                    m_appInfoToAppModelIndex.remove(appInfo);
                    m_appModelIndexToAppInfo.remove(i);
                }
            });

    connect(appModel, &QAbstractItemModel::modelAboutToBeReset, this,
            [this]()
            {
                beginResetModel();
                m_resetting = true;
                m_list.clear();
            });

    connect(appModel, &QAbstractItemModel::modelReset, this,
            [this]()
            {
                setPopulating(true);
                trackRowsFromApplicationModel(0, m_applicationModel->rowCount() - 1);
                setPopulating(false);
                m_resetting = false;
                endResetModel();
            });

    connect(appModel, &QObject::destroyed, this,
            [this]()
            {
                this->setApplicationModel(nullptr);
            });
}

void WidgetListModel::fetchAppInfoRoleIndex()
{
    QHash<int, QByteArray> hash = m_applicationModel->roleNames();

    m_appInfoRoleIndex = -1;
    for (auto i = hash.constBegin(); i != hash.constEnd() && m_appInfoRoleIndex == -1; ++i) {
        if (i.value() == QByteArrayLiteral("appInfo"))
            m_appInfoRoleIndex = i.key();
    }

    Q_ASSERT(m_appInfoRoleIndex != -1);
}

QObject *WidgetListModel::application(int rowIndex)
{
    if (rowIndex >= 0 && rowIndex < m_list.count()) {
        return m_list[rowIndex].appInfo;
    } else {
        return nullptr;
    }
}

void WidgetListModel::move(int from, int to)
{
    qDebug().nospace() << "WidgetListModel::move(from="<<from<<", to="<<to<<")";

    if (from == to) return;

    if (from >= 0 && from < m_list.size() && to >= 0 && to < m_list.size()) {
        QModelIndex parent;
        /* When moving an item down, the destination index needs to be incremented
           by one, as explained in the documentation:
           http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */

        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
        m_list.move(from, to);
        endMoveRows();

        updateRowIndexes();
    }
}

void WidgetListModel::onAppWidgetStateChanged()
{
    QObject *appInfo = sender();
    if (asWidget(appInfo)) {
        appendApplicationInfo(appInfo);
    } else {
        detachApplicationInfo(appInfo);
    }
}

void WidgetListModel::trackRowsFromApplicationModel(int first, int last)
{
    QList<ListItem> newRows;

    for (int i = first; i <= last; ++i) {
        auto *appInfo = getApplicationInfoFromModelAt(i);

        m_appInfoToAppModelIndex[appInfo] = i;
        m_appModelIndexToAppInfo[i] = appInfo;

        if (!hasWidgetSupport(appInfo)) {
            continue;
        }

        bool ok;
        ok = connect(appInfo, SIGNAL(asWidgetChanged()), this, SLOT(onAppWidgetStateChanged()));
        if (!ok) qFatal("WidgetListModel: Failed to connect to ApplicationInfo::asWidgetChanged");

        ok = connect(appInfo, SIGNAL(heightRowsChanged()), this, SLOT(updateRowIndexes()));
        if (!ok) qFatal("WidgetListModel: Failed to connect to ApplicationInfo::heightRowsChanged");

        if (asWidget(appInfo)) {
            newRows.append(ListItem(appInfo));
        }
    }

    if (newRows.isEmpty()) {
        return;
    }

    if (!m_resetting) {
        beginInsertRows(QModelIndex(), rowCount()/*first*/, rowCount() + newRows.count() - 1/*last*/);
    }

    m_list.append(newRows);

    if (!m_resetting) {
        endInsertRows();
    }
    emit countChanged();

    updateRowIndexes();
}

void WidgetListModel::appendApplicationInfo(QObject *appInfo)
{
    // TODO: consider minHeight

    // Shrink existing widgets to make way for the new one
    auto list = filterOutDetachedItems(m_list);
    if (list.count() > 0) {
        for (int i = list.count() - 1; i >= 0; --i) {
            auto *appInfo = list[i]->appInfo;
            if (heightRows(appInfo) > 1) {
                setHeightRows(appInfo, heightRows(appInfo) - 1);
                break;
            }
        }
    }

    if (list.count() == 1) {
        setHeightRows(appInfo, m_totalNumRows - heightRows(list[0]->appInfo));
    } else {
        setHeightRows(appInfo, 1);
    }

    beginInsertRows(QModelIndex(), rowCount()/*first*/, rowCount()/*last*/);
    m_list.append(ListItem(appInfo));
    updateRowIndexes();
    endInsertRows();
    emit countChanged();
}

void WidgetListModel::detachApplicationInfo(QObject *appInfoToRemove)
{
    int index = indexFromAppInfo(appInfoToRemove);
    if (index == -1) {
        return;
    }

    m_list[index].detached = true;

    QList<ListItem*> attachedItems = filterOutDetachedItems(m_list);

    if (attachedItems.count() == 1) {
        // Special case when there's only one widget left
        setHeightRows(attachedItems[0]->appInfo, m_maxWidgetHeightRows);
        updateRowIndexes();
    } else {
        distributeHeightOfDetachedAppInfo(index);
    }
}

/*
    Distribute the height of the given detached application among there remaining ones.

    From closest to farthest neighbor.
 */
void WidgetListModel::distributeHeightOfDetachedAppInfo(int indexOfDetacheItem)
{
    int remainingHeight = heightRows(m_list[indexOfDetacheItem].appInfo);
    int iAbove = indexOfDetacheItem - 1;
    int iBelow = indexOfDetacheItem + 1;

    auto giveRemainingHeight = [&](QObject *appInfo) {
        int availableHeight = m_maxWidgetHeightRows - heightRows(appInfo);
        int heightIncrement = qMin(availableHeight, qMin(remainingHeight, m_maxWidgetHeightRows));
        setHeightRows(appInfo, heightRows(appInfo) + heightIncrement);
        remainingHeight -= heightIncrement;
    };

    while (remainingHeight > 0 && (iAbove >= 0 || iBelow < m_list.count())) {
        while (true) {
            if (iAbove < 0) {
                // no items left above
                break;
            } else if (m_list[iAbove].detached) {
                // try the previous one
                --iAbove;
            } else {
                // do it
                giveRemainingHeight(m_list[iAbove].appInfo);
                --iAbove;
                break;
            }
        }

        while (true) {
            if (iBelow >= m_list.count()) {
                // no items left below
                break;
            } else if (m_list[iBelow].detached) {
                // try the next one
                ++iBelow;
            } else {
                // do it
                giveRemainingHeight(m_list[iBelow].appInfo);
                ++iBelow;
                break;
            }
        }
    }
}

void WidgetListModel::remove(int index)
{
    if (index >= 0 && index < m_list.count()) {
        beginRemoveRows(QModelIndex(), index, index);
        m_list.removeAt(index);
        endRemoveRows();
        emit countChanged();
    }
}

QObject *WidgetListModel::getApplicationInfoFromModelAt(int index)
{
    fetchAppInfoRoleIndex();

    auto rowIndex = m_applicationModel->index(index, 0, QModelIndex());
    QVariant variant = m_applicationModel->data(rowIndex, m_appInfoRoleIndex);
    auto appInfo = variant.value<QObject*>();

    if (!appInfo) {
        qFatal("WidgetListModel: Invalid source model");
    }

    return appInfo;
}

void WidgetListModel::updateRowIndexes()
{
    if (m_updatingRowIndexes) {
        // avoid recursion
        return;
    }

    m_updatingRowIndexes = true;

    QVector<int> roles;
    roles.append(RoleRowIndex);

    auto list = filterOutDetachedItems(m_list);

    if (list.count() == 1) {
        ListItem *listItem = list[0];

        // special case. Have it centered
        listItem->rowIndex = (m_totalNumRows - heightRows(listItem->appInfo)) / 2;

        auto modelIndex = index(indexFromAppInfo(listItem->appInfo));
        emit dataChanged(modelIndex, modelIndex, roles);
    } else {
        int accumulatedRows = 0;
        for (int i = 0; i < m_list.count(); ++i) {
            ListItem &listItem = m_list[i];

            if (listItem.detached)
                continue;

            if (accumulatedRows != listItem.rowIndex) {
                listItem.rowIndex = accumulatedRows;

                auto modelIndex = index(i);
                emit dataChanged(modelIndex, modelIndex, roles);
            }

            accumulatedRows += heightRows(listItem.appInfo);
        }
    }

    m_updatingRowIndexes = false;
}

int WidgetListModel::indexFromAppInfo(QObject *appInfo)
{
    for (int i = 0; i < m_list.count(); ++i) {
        if (m_list[i].appInfo == appInfo) {
            return i;
        }
    }
    return -1;
}

int WidgetListModel::heightRows(QObject* appInfo) const
{
    return appInfo->property("heightRows").toInt();
}

void WidgetListModel::setHeightRows(QObject* appInfo, int value) const
{
    appInfo->setProperty("heightRows", QVariant(value));
}

bool WidgetListModel::asWidget(QObject *appInfo) const
{
    return appInfo->property("asWidget").toBool();
}

QString WidgetListModel::id(QObject *appInfo) const
{
    return appInfo->property("id").toString();
}

bool WidgetListModel::hasWidgetSupport(QObject *appInfo) const
{
    return appInfo->property("categories").toStringList().contains(QStringLiteral("widget"));
}

QList<WidgetListModel::ListItem*> WidgetListModel::filterOutDetachedItems(QList<ListItem> &list) const
{
    QList<ListItem*> filteredList;
    for (int i = 0; i < list.count(); ++i) {
        if (!list[i].detached) {
            filteredList.append(&list[i]);
        }
    }
    return filteredList;
}

void WidgetListModel::setPopulating(bool value)
{
    if (m_populating != value) {
        m_populating = value;
        emit populatingChanged();
    }
}
