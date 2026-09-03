#include "FolderModel.h"

#include <QDir>
#include <QFileInfo>
#include <QSet>

namespace {
const QSet<QString> kSupportedExtensions = {
    "png", "jpg", "jpeg", "bmp", "tga", "gif", "psd", "hdr", "pic", "pnm", "ppm", "pgm",
};
}

FolderModel::FolderModel(QObject *parent) : QAbstractListModel(parent) {}

int FolderModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_entries.size();
}

QVariant FolderModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_entries.size())
        return {};

    const QString &path = m_entries.at(index.row());
    switch (role) {
    case FilePathRole:
        return path;
    case FileNameRole:
        return QFileInfo(path).fileName();
    default:
        return {};
    }
}

QHash<int, QByteArray> FolderModel::roleNames() const
{
    return {
        {FilePathRole, "filePath"},
        {FileNameRole, "fileName"},
    };
}

void FolderModel::setDirectory(const QString &dirPath, const QString &currentFilePath)
{
    beginResetModel();
    m_entries.clear();
    QDir dir(dirPath);
    const auto infos = dir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot, QDir::Name);
    for (const QFileInfo &info : infos) {
        if (kSupportedExtensions.contains(info.suffix().toLower()))
            m_entries.append(info.absoluteFilePath());
    }
    endResetModel();
    emit countChanged();
    setCurrentPath(currentFilePath);
}

void FolderModel::setCurrentPath(const QString &filePath)
{
    int idx = m_entries.indexOf(QFileInfo(filePath).absoluteFilePath());
    if (idx < 0)
        idx = 0;
    if (idx != m_currentIndex) {
        m_currentIndex = idx;
        emit currentIndexChanged();
    }
}

QString FolderModel::next()
{
    if (m_entries.isEmpty())
        return {};
    m_currentIndex = (m_currentIndex + 1) % m_entries.size();
    emit currentIndexChanged();
    return m_entries.at(m_currentIndex);
}

QString FolderModel::previous()
{
    if (m_entries.isEmpty())
        return {};
    m_currentIndex = (m_currentIndex - 1 + m_entries.size()) % m_entries.size();
    emit currentIndexChanged();
    return m_entries.at(m_currentIndex);
}

QString FolderModel::filePathAt(int index) const
{
    if (index < 0 || index >= m_entries.size())
        return {};
    return m_entries.at(index);
}
