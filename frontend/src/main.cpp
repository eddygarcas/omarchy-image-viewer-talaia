#include <QCoreApplication>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>

#include "ImageBackend.h"
#include "ImageProvider.h"
#include "ThemeReader.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Talaia");
    app.setOrganizationName("talaia");
    app.setWindowIcon(QIcon(QStringLiteral(":/resources/icons/talaia.svg")));

    ImageBackend backend;
    ThemeReader themeReader;

    QQmlApplicationEngine engine;
    engine.addImageProvider(QStringLiteral("backend"), new ImageProvider(&backend));
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("themeReader", &themeReader);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        [] { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/ImageViewer/qml/main.qml")));

    if (argc > 1)
        backend.openImage(QString::fromLocal8Bit(argv[1]));

    return app.exec();
}
