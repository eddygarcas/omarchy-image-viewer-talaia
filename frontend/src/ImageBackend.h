#pragma once

#include <QImage>
#include <QObject>
#include <QString>

#include "FolderModel.h"
#include "imgbackend.h"

class ImageBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int generation READ generation NOTIFY imageChanged)
    Q_PROPERTY(int imageWidth READ imageWidth NOTIFY imageChanged)
    Q_PROPERTY(int imageHeight READ imageHeight NOTIFY imageChanged)
    Q_PROPERTY(bool hasImage READ hasImage NOTIFY imageChanged)
    Q_PROPERTY(QString currentPath READ currentPath NOTIFY imageChanged)
    Q_PROPERTY(FolderModel *folderModel READ folderModel CONSTANT)

public:
    explicit ImageBackend(QObject *parent = nullptr);
    ~ImageBackend() override;

    int generation() const { return m_generation; }
    int imageWidth() const { return m_width; }
    int imageHeight() const { return m_height; }
    bool hasImage() const { return m_handle != nullptr; }
    QString currentPath() const { return m_currentPath; }
    FolderModel *folderModel() const { return m_folderModel; }

    /// Wraps the backend's current pixel buffer with zero-copy ownership
    /// transfer: QImage frees it via img_free_pixels when it's done.
    QImage currentQImage() const;

    Q_INVOKABLE bool openImage(const QString &path);
    Q_INVOKABLE void rotate(bool clockwise);
    Q_INVOKABLE void flip(bool horizontal);
    Q_INVOKABLE void crop(int x, int y, int w, int h);
    Q_INVOKABLE void resizeImage(int w, int h);
    Q_INVOKABLE void adjust(qreal brightness, qreal contrast, qreal saturation);
    Q_INVOKABLE void commitAdjust();
    Q_INVOKABLE void undo();
    Q_INVOKABLE void redo();
    Q_INVOKABLE void resetImage();
    Q_INVOKABLE bool saveImage(const QString &path);

signals:
    void imageChanged();
    void errorOccurred(const QString &message);

private:
    void closeCurrent();
    void refreshDimensions();
    void bump();

    ImgHandle m_handle = nullptr;
    int m_width = 0;
    int m_height = 0;
    int m_generation = 0;
    QString m_currentPath;
    FolderModel *m_folderModel;
};
