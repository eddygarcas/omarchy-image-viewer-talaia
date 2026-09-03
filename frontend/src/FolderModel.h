#pragma once

#include <QAbstractListModel>
#include <QStringList>

class FolderModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)

public:
    enum Roles {
        FilePathRole = Qt::UserRole + 1,
        FileNameRole,
    };

    explicit FolderModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_entries.size(); }
    int currentIndex() const { return m_currentIndex; }

    Q_INVOKABLE void setDirectory(const QString &dirPath, const QString &currentFilePath = QString());
    Q_INVOKABLE QString next();
    Q_INVOKABLE QString previous();
    Q_INVOKABLE QString filePathAt(int index) const;
    Q_INVOKABLE void setCurrentPath(const QString &filePath);

signals:
    void countChanged();
    void currentIndexChanged();

private:
    QStringList m_entries;
    int m_currentIndex = 0;
};
