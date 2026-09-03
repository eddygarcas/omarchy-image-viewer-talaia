#pragma once

#include <QQuickImageProvider>

class ImageBackend;

class ImageProvider : public QQuickImageProvider
{
public:
    explicit ImageProvider(ImageBackend *backend);

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    ImageBackend *m_backend;
};
