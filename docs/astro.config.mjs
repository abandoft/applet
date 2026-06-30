import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://abandoft.github.io',
  base: '/applet',
  integrations: [
    starlight({
      title: 'Applet',
      description:
        'A JavaScript hot-update framework for native Flutter UI.',
      logo: {
        src: './src/assets/logo.svg',
      },
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/abandoft/applet',
        },
      ],
      locales: {
        root: {
          label: 'English',
          lang: 'en',
        },
        zh: {
          label: '简体中文',
          lang: 'zh-CN',
        },
      },
      customCss: ['./src/styles/site.css'],
      editLink: {
        baseUrl: 'https://github.com/abandoft/applet/edit/main/docs/',
      },
      sidebar: [
        {
          label: 'Overview',
          translations: { 'zh-CN': '概览' },
          items: ['index'],
        },
        {
          label: 'Quick start',
          translations: { 'zh-CN': '快速开始' },
          items: [{ autogenerate: { directory: 'quick-start' } }],
        },
        {
          label: 'Tutorial',
          translations: { 'zh-CN': '入门教程' },
          items: [{ autogenerate: { directory: 'tutorial' } }],
        },
        {
          label: 'Advanced usage',
          translations: { 'zh-CN': '高级用法' },
          items: [{ autogenerate: { directory: 'advanced' } }],
        },
        {
          label: 'Development',
          translations: { 'zh-CN': '开发文档' },
          items: [{ autogenerate: { directory: 'development' } }],
        },
        {
          label: 'API',
          translations: { 'zh-CN': 'API' },
          items: [{ autogenerate: { directory: 'api' } }],
        },
      ],
    }),
  ],
});
