// SAST only (Lab 06): general linting stays with oxlint (npm run lint).
// This config just parses TypeScript and turns on eslint-plugin-security's rules.
import tseslint from 'typescript-eslint';
import security from 'eslint-plugin-security';

export default tseslint.config(
  { ignores: ['dist/**', 'coverage/**', 'node_modules/**'] },
  // Existing eslint-disable comments target oxlint rules, so don't flag them as unused here
  { linterOptions: { reportUnusedDisableDirectives: 'off' } },
  {
    files: ['src/**/*.{ts,js}'],
    languageOptions: { parser: tseslint.parser },
    // Loaded here too so plain `npx eslint src/` behaves the same as the pipeline's `--plugin security`
    plugins: { security },
    rules: security.configs.recommended.rules,
  },
);
