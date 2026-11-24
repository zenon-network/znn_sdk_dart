// @ts-check
import { themes as prismThemes } from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Zenon Dart SDK',
  tagline: 'Dart & Flutter SDK for Zenon — Network of Momentum',
  favicon: 'img/favicon.svg',

  url: 'https://zenon-network.github.io',
  baseUrl: '/znn_sdk_dart/',

  organizationName: 'zenon-network',
  projectName: 'znn_sdk_dart',
  trailingSlash: false,

  onBrokenLinks: 'throw',

  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'throw',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          routeBasePath: '/',
          sidebarPath: './sidebars.js',
          editUrl:
            'https://github.com/zenon-network/znn_sdk_dart/tree/master/docs/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themes: [
    [
      '@easyops-cn/docusaurus-search-local',
      /** @type {import('@easyops-cn/docusaurus-search-local').PluginOptions} */
      ({
        hashed: true,
        indexDocs: true,
        indexBlog: false,
        indexPages: false,
        language: ['en'],
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        defaultMode: 'dark',
        respectPrefersColorScheme: false,
      },
      navbar: {
        title: 'Zenon Dart SDK',
        logo: {
          alt: 'ZNN',
          src: 'img/znn-logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'docs',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://pub.dev/packages/znn_sdk_dart',
            label: 'pub.dev',
            position: 'right',
          },
          {
            href: 'https://github.com/zenon-network/znn_sdk_dart',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              { label: 'Getting started', to: '/getting-started/installation' },
              { label: 'API reference', to: '/api/zenon' },
            ],
          },
          {
            title: 'Network of Momentum',
            items: [
              { label: 'zenon.network', href: 'https://zenon.network' },
              { label: 'Zenon on GitHub', href: 'https://github.com/zenon-network' },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'znn_sdk_dart repository',
                href: 'https://github.com/zenon-network/znn_sdk_dart',
              },
            ],
          },
        ],
        copyright: `Zenon — Network of Momentum. Feeless, by design.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.vsDark,
        additionalLanguages: ['dart', 'bash', 'json', 'yaml'],
      },
    }),
};

export default config;
