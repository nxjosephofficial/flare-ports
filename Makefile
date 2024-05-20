PORTNAME=	flare
DISTVERSION=	0.14.3
CATEGORIES=	net-im

MAINTAINER=	mikael@FreeBSD.org
COMMENT=	Chat with your friends on Signal
WWW=		https://gitlab.com/schmiddi-on-mobile/flare

LICENSE=	AGPLv3
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	blueprint-compiler:devel/blueprint-compiler \
		protoc:devel/protobuf
#LIB_DEPENDS=	libdbus-1.so:devel/dbus \
#		libgdk_pixbuf-2.0.so:graphics/gdk-pixbuf2 \
#		libsecret-1.so:security/libsecret

USES=		cargo desktop-file-utils gettext gnome meson pkgconfig
USE_GNOME=	gtksourceview5 gtk40 libadwaita

USE_GITLAB=	yes
GL_ACCOUNT=	schmiddi-on-mobile
#GL_TAGNAME=	a5d5b6b3e3deadee0ddf458bfc726b82bafc9a6a

MAKE_ENV+=	${CARGO_ENV}
CARGO_BUILD=	no
CARGO_INTALL=	no
CARGO_TEST=	no
GLIB_SCHEMAS=	de.schmidhuberj.Flare.gschema.xml
MAKE_ENV+=	PYTHONDONTWRITEBYTECODE=1

# XXX add libspelling for spell-checking support
# https://gitlab.gnome.org/chergert/libspelling (no port yet)
OPTIONS_DEFINE=	FEEDBACK
FEEDBACK_DESC=	for vibrating notifications
FEEDBACK_LIB_DEPENDS=	libfeedback-0.0.so:accessibility/feedbackd

.include <bsd.port.options.mk>

.if ${OPSYS} == FreeBSD && ( ${OSVERSION} >= 1400091 || ( ${OSVERSION} >= 1302507 && ${OSVERSION} < 1400000 ))
CFLAGS+=	-Wno-error=incompatible-function-pointer-types
.endif

post-patch:
	@${REINPLACE_CMD} -e '/update_desktop_database/d' \
		${WRKSRC}/meson.build
# Make each cargo subcommand very verbose
# Add explicit <triple> subdir for --target from USES=cargo
	@${REINPLACE_CMD} -e "/cargo_options =/s/ '--/&verbose', &verbose', &/" \
		-e "/cp/s,'target',& / '${CARGO_BUILD_TARGET}'," \
		${WRKSRC}/src/meson.build

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/share/dbus-1/system-services \
		 ${STAGEDIR}${PREFIX}/share/glib-2.0/schemas \
		 ${STAGEDIR}${PREFIX}/share/icons/hicolor/scalable/apps \
		 ${STAGEDIR}${PREFIX}/share/icons/hicolor/symbolic/apps \
		 ${STAGEDIR}${PREFIX}/share/metainfo
	${INSTALL_PROGRAM} ${WRKSRC}/${MESON_BUILD_DIR}/target/${CARGO_BUILD_TARGET}/*/flare ${STAGEDIR}${PREFIX}/bin
	${INSTALL_DATA} ${WRKSRC}/${MESON_BUILD_DIR}/data/de.schmidhuberj.Flare.service ${STAGEDIR}${PREFIX}/share/dbus-1/system-services/
	${INSTALL_DATA} ${WRKSRC}/${MESON_BUILD_DIR}/data/de.schmidhuberj.Flare.desktop ${STAGEDIR}${PREFIX}/share/applications/
	${INSTALL_DATA} ${WRKSRC}/_build/data/de.schmidhuberj.Flare.metainfo.xml ${STAGEDIR}${PREFIX}/share/metainfo/
	${INSTALL_DATA} ${WRKSRC}/data/de.schmidhuberj.Flare.gschema.xml ${STAGEDIR}${PREFIX}/share/glib-2.0/schemas/
	${INSTALL_DATA} ${WRKSRC}/data/icons/de.schmidhuberj.Flare.svg ${STAGEDIR}${PREFIX}/share/icons/hicolor/scalable/apps/
	${INSTALL_DATA} ${WRKSRC}/data/icons/de.schmidhuberj.Flare-symbolic.svg ${STAGEDIR}${PREFIX}/share/icons/hicolor/symbolic/apps/

.include <bsd.port.mk>
