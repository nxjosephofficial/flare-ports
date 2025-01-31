PORTNAME=	flare
DISTVERSION=	0.15.8
CATEGORIES=	net-im

MAINTAINER=	nxjoseph@protonmail.com
COMMENT=	Chat with your friends on Signal
WWW=		https://gitlab.com/schmiddi-on-mobile/flare

LICENSE=	AGPLv3
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	blueprint-compiler:devel/blueprint-compiler \
		protoc:devel/protobuf
LIB_DEPENDS=	libdbus-1.so:devel/dbus \
		libgdk_pixbuf-2.0.so:graphics/gdk-pixbuf2 \
		libsecret-1.so:security/libsecret
RUN_DEPENDS=	gnome-keyring:security/gnome-keyring

USES=		cargo desktop-file-utils gettext-tools gnome meson pathfix \
		pkgconfig
USE_GITLAB=	yes
GL_ACCOUNT=	schmiddi-on-mobile
USE_GNOME=	gtk40 gtksourceview5 libadwaita
GLIB_SCHEMAS=	de.schmidhuberj.Flare.gschema.xml

CARGO_BUILD=	no
CARGO_INSTALL=	no
CARGO_TEST=	no

MAKE_ENV+=	${CARGO_ENV} \
		PYTHONDONTWRITEBYTECODE=1

OPTIONS_DEFINE=		FEEDBACK SPELLCHECK
FEEDBACK_DESC=		for vibrating notifications
SPELLCHECK_DESC=	for spell-checking support
FEEDBACK_LIB_DEPENDS=	libfeedback-0.0.so:accessibility/feedbackd
SPELLCHECK_LIB_DEPENDS=	libspelling-1.so:x11-toolkits/libspelling

GL_TAGNAME=	f412701ad8eb30d8ff0aa15db5cbc4997b21b340

.include <bsd.port.options.mk>

.if ${OPSYS} == FreeBSD && (${OSVERSION} >= 1400091 || (${OSVERSION} >= 1302507 && \
	${OSVERSION} < 1400000))
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
	${INSTALL_PROGRAM} ${WRKSRC}/${MESON_BUILD_DIR}/target/${CARGO_BUILD_TARGET}/*/flare \
		${STAGEDIR}${PREFIX}/bin
	${INSTALL_DATA} ${WRKSRC}/${MESON_BUILD_DIR}/data/de.schmidhuberj.Flare.service \
		${STAGEDIR}${PREFIX}/share/dbus-1/system-services/
	${INSTALL_DATA} ${WRKSRC}/${MESON_BUILD_DIR}/data/de.schmidhuberj.Flare.desktop \
		${STAGEDIR}${PREFIX}/share/applications/
	${INSTALL_DATA} ${WRKSRC}/_build/data/de.schmidhuberj.Flare.metainfo.xml \
		${STAGEDIR}${PREFIX}/share/metainfo/
	${INSTALL_DATA} ${WRKSRC}/data/de.schmidhuberj.Flare.gschema.xml \
		${STAGEDIR}${PREFIX}/share/glib-2.0/schemas/
	${INSTALL_DATA} ${WRKSRC}/data/icons/de.schmidhuberj.Flare.svg \
		${STAGEDIR}${PREFIX}/share/icons/hicolor/scalable/apps/
	${INSTALL_DATA} ${WRKSRC}/data/icons/de.schmidhuberj.Flare-symbolic.svg \
		${STAGEDIR}${PREFIX}/share/icons/hicolor/symbolic/apps/

.include <bsd.port.mk>
