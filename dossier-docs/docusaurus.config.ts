import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import {themes as prismThemes} from 'prism-react-renderer';

const config: Config = {
  title: 'Dossier de validation — YapServer',
  tagline: 'Preuves, interrogatoires et suivi du dossier',
  url: 'https://dossier.yapserver.fr',
  baseUrl: '/',
  favicon: 'img/favicon.svg',
  onBrokenLinks: 'warn',
  organizationName: 'yapcyber',
  projectName: 'homelab',
  i18n: {defaultLocale: 'fr', locales: ['fr']},
  presets: [[
    'classic',
    {
      docs: {sidebarPath: './sidebars.ts', routeBasePath: '/'},
      blog: false,
      pages: false,
      theme: {customCss: './src/css/custom.css'},
      sitemap: false,
    } satisfies Preset.Options,
  ]],
  themeConfig: {
    navbar: {
      title: 'Dossier de validation',
      logo: {alt: 'YapServer', src: 'img/logo.svg'},
      items: [
        {type: 'docSidebar', sidebarId: 'docsSidebar', label: 'Sommaire', position: 'left'},
      ],
    },
    footer: {
      style: 'dark',
      links: [{title: 'Dossier', items: [
        {label: 'Accueil', to: '/'},
        {label: 'Suivi des preuves', to: '/preuves/suivi'},
      ]}],
      copyright: `Dossier de validation privé · YapServer · ${new Date().getFullYear()}`,
    },
    colorMode: {defaultMode: 'dark', respectPrefersColorScheme: true},
    prism: {theme: prismThemes.github, darkTheme: prismThemes.dracula},
  } satisfies Preset.ThemeConfig,
};

export default config;
