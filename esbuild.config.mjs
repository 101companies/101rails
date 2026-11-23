// Bundles app/javascript -> app/assets/builds (served by Propshaft).
//
//   node esbuild.config.mjs            one-off build
//   node esbuild.config.mjs --watch    watch mode (used by `bin/dev`)
//
// NODE_ENV=production or RAILS_ENV=production minifies and drops sourcemaps.
import { mkdirSync, readdirSync, rmSync } from 'node:fs';
import esbuild from 'esbuild';

const watch = process.argv.includes('--watch');
// `rails assets:precompile` sets RAILS_ENV (not NODE_ENV), so honour both.
const production =
  process.env.NODE_ENV === 'production' || process.env.RAILS_ENV === 'production';

const outdir = 'app/assets/builds';

// Propshaft copies everything under app/assets, so stale output from a previous
// build (e.g. an unminified bundle with sourcemaps) must not be shipped.
mkdirSync(outdir, { recursive: true });
for (const file of readdirSync(outdir)) {
  if (file !== '.keep') rmSync(`${outdir}/${file}`, { recursive: true, force: true });
}

const shared = {
  bundle: true,
  outdir,
  sourcemap: !production,
  minify: production,
  logLevel: 'info',
  target: ['es2020'],
  define: {
    'process.env.NODE_ENV': JSON.stringify(production ? 'production' : 'development'),
  },
  // JSX is used in .js files too, so don't rely on the .jsx extension.
  loader: { '.js': 'jsx', '.jsx': 'jsx' },
};

const js = { ...shared, entryPoints: ['app/javascript/application.js'] };
const css = { ...shared, entryPoints: ['app/javascript/styles/application.css'] };

if (watch) {
  const ctx = await esbuild.context({ ...js, entryPoints: [...js.entryPoints, ...css.entryPoints] });
  await ctx.watch();
  console.log('esbuild watching for changes...');
} else {
  await esbuild.build(js);
  await esbuild.build(css);
}
