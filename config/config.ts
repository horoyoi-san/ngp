import { defineConfig } from '@umijs/max';

export default defineConfig({
  title: 'Ananta Gateway Control',
  routes: [
    {
      path: '/',
      component: '@/layouts/index',
      routes: [
        { path: '/', component: '@/pages/index' },
        { path: '/game-commands', component: '@/pages/GameCommands' },
        { path: '/about', component: '@/pages/about' },
      ]
    },
  ],
  npmClient: 'npm',
  antd: {},
  layout: false,
  history: { type: 'hash' },
  publicPath: process.env.NODE_ENV === 'production' ? './' : '/',
  outputPath: 'dist',
  esbuildMinifyIIFE: true,
});
