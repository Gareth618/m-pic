const onloadPhotosJS = window.onload || (() => { });
window.onload = () => {
  const columns = [...document.getElementById('photos').children];
  columns.forEach((column, index) => {
    const photos = column.getAttribute('data-order').split(', ');
    let html = '';
    for (const photo of photos) {
      if (Number.isNaN(parseInt(photo))) {
        html += `<div><div style="background: var(--${photo})"></div></div>`;
      }
      else {
        html += `
          <picture>
            <source srcset="../assets/photos/avif/${photo}.avif" type="image/avif">
            <source srcset="../assets/photos/webp/${photo}.webp" type="image/webp">
            <img src="../assets/photos/jpg/${photo}.jpg" alt="photo">
          </picture>
        `;
      }
    }
    column.innerHTML = html;

    column.scrollTop = 480;
    let offset = 0;
    const scroll = () => {
      offset = (offset + 1) % 240;
      for (const child of column.children) {
        const transform = `translateY(${offset * (index % 2 === 1 ? +1 : -1)}px)`;
        if (child.tagName === "DIV") {
          child.style.transform = transform;
        }
        else {
          child.children[2].style.transform = transform;
        }
      }
      if (offset === 0) {
        if (index % 2 === 0) {
          const child = column.children[0];
          column.append(child.cloneNode(true));
          column.removeChild(child);
        }
        else {
          const child = column.children[column.children.length - 1];
          column.removeChild(child);
          column.prepend(child.cloneNode(true));
        }
      }
      setTimeout(scroll, (index + 1) * 6);
    };
    scroll();
  });
  onloadPhotosJS();
};