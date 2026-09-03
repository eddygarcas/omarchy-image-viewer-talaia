#include "ImageProvider.h"

#include "ImageBackend.h"

ImageProvider::ImageProvider(ImageBackend *backend)
    : QQuickImageProvider(QQuickImageProvider::Image), m_backend(backend)
{
}

QImage ImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(id);         // id only carries the generation counter, to bust QML's image cache
    Q_UNUSED(requestedSize); // full-resolution image is returned; QML scales it down for display

    const QImage image = m_backend->currentQImage();
    if (size)
        *size = image.size();
    return image;
}
