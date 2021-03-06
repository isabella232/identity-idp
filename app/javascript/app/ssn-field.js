import Cleave from 'cleave.js';

const { I18n } = window.LoginGov;

/* eslint-disable no-new */
function formatSSNField() {
  const inputs = document.querySelectorAll('input.ssn-toggle[type="password"]');

  if (inputs) {
    [].slice.call(inputs).forEach((input, i) => {
      const el = `
        <div class="mt1 right">
          <label class="btn-border" for="ssn-toggle-${i}">
            <div class="checkbox">
              <input id="ssn-toggle-${i}" type="checkbox">
              <span class="indicator"></span>
              ${I18n.t('forms.ssn.show')}
            </div>
          </label>
        </div>`;
      input.insertAdjacentHTML('afterend', el);

      const toggle = document.getElementById(`ssn-toggle-${i}`);

      let cleave;

      function sync() {
        const { value } = input;
        input.type = toggle.checked ? 'text' : 'password';
        cleave?.destroy();
        if (toggle.checked) {
          cleave = new Cleave(input, {
            numericOnly: true,
            blocks: [3, 2, 4],
            delimiter: '-',
          });
        } else {
          const nextValue = value.replace(/-/g, '');
          if (nextValue !== value) {
            input.value = nextValue;
          }
        }
        const didFormat = input.value !== value;
        if (didFormat) {
          input.checkValidity();
        }
      }

      sync();
      toggle.addEventListener('change', sync);
    });
  }
}

document.addEventListener('DOMContentLoaded', formatSSNField);
