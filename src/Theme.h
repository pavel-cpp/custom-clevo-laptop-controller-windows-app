#pragma once

#include <QColor>
#include <QObject>
#include <QString>

// Design tokens exposed to QML as a root-context property. Implemented in
// C++ (rather than as a QML `pragma Singleton`) so that property lookups
// stay reliable inside dynamically-created Repeater delegates, where the
// AOT-compiled QML singleton import was observed to intermittently resolve
// to undefined.
class Theme : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QColor windowFill READ windowFill CONSTANT)
    Q_PROPERTY(QColor accent READ accent CONSTANT)
    Q_PROPERTY(QColor accentHover READ accentHover CONSTANT)
    Q_PROPERTY(QColor accentText READ accentText CONSTANT)
    Q_PROPERTY(QColor closeHover READ closeHover CONSTANT)

    Q_PROPERTY(QColor textPrimary READ textPrimary CONSTANT)
    Q_PROPERTY(QColor textSecondary READ textSecondary CONSTANT)
    Q_PROPERTY(QColor textMuted READ textMuted CONSTANT)
    Q_PROPERTY(QColor textFaint READ textFaint CONSTANT)
    Q_PROPERTY(QColor textDim READ textDim CONSTANT)

    Q_PROPERTY(QColor panelBg READ panelBg CONSTANT)
    Q_PROPERTY(QColor panelBgHover READ panelBgHover CONSTANT)
    Q_PROPERTY(QColor panelBgStrong READ panelBgStrong CONSTANT)
    Q_PROPERTY(QColor panelBorder READ panelBorder CONSTANT)
    Q_PROPERTY(QColor panelBorder2 READ panelBorder2 CONSTANT)
    Q_PROPERTY(QColor hoverBg READ hoverBg CONSTANT)
    Q_PROPERTY(QColor selectedBg READ selectedBg CONSTANT)
    Q_PROPERTY(QColor separator READ separator CONSTANT)
    Q_PROPERTY(QColor separator2 READ separator2 CONSTANT)

    Q_PROPERTY(QColor fieldBg READ fieldBg CONSTANT)
    Q_PROPERTY(QColor fieldBorder READ fieldBorder CONSTANT)
    Q_PROPERTY(QColor fieldBorderBottom READ fieldBorderBottom CONSTANT)

    Q_PROPERTY(QString fontFamily READ fontFamily CONSTANT)

    Q_PROPERTY(int radius READ radius CONSTANT)
    Q_PROPERTY(int radiusSm READ radiusSm CONSTANT)
    Q_PROPERTY(int navExpandedWidth READ navExpandedWidth CONSTANT)
    Q_PROPERTY(int navCollapsedWidth READ navCollapsedWidth CONSTANT)

public:
    explicit Theme(QObject *parent = nullptr) : QObject(parent) {}

    static QColor white(qreal a) { return QColor::fromRgbF(1, 1, 1, a); }
    static QColor black(qreal a) { return QColor::fromRgbF(0, 0, 0, a); }
    Q_INVOKABLE QColor whiteAlpha(qreal a) const { return white(a); }
    Q_INVOKABLE QColor blackAlpha(qreal a) const { return black(a); }

    QColor windowFill() const { return QColor::fromRgbF(0.1098f, 0.1098f, 0.1333f, 0.66f); }
    QColor accent() const { return QColor("#4cc2ff"); }
    QColor accentHover() const { return QColor("#63cdff"); }
    QColor accentText() const { return QColor("#10222e"); }
    QColor closeHover() const { return QColor("#c42b1c"); }

    QColor textPrimary() const { return white(1.0); }
    QColor textSecondary() const { return white(0.62); }
    QColor textMuted() const { return white(0.55); }
    QColor textFaint() const { return white(0.45); }
    QColor textDim() const { return white(0.68); }

    QColor panelBg() const { return white(0.045); }
    QColor panelBgHover() const { return white(0.075); }
    QColor panelBgStrong() const { return white(0.06); }
    QColor panelBorder() const { return white(0.08); }
    QColor panelBorder2() const { return white(0.07); }
    QColor hoverBg() const { return white(0.07); }
    QColor selectedBg() const { return white(0.085); }
    QColor separator() const { return white(0.05); }
    QColor separator2() const { return white(0.06); }

    QColor fieldBg() const { return white(0.06); }
    QColor fieldBorder() const { return white(0.10); }
    QColor fieldBorderBottom() const { return white(0.40); }

    QString fontFamily() const { return QStringLiteral("Segoe UI Variable Text"); }

    int radius() const { return 8; }
    int radiusSm() const { return 5; }
    int navExpandedWidth() const { return 232; }
    int navCollapsedWidth() const { return 60; }
};
