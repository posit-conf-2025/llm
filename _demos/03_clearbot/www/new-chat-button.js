// Select the .navbar .navbar-brand element
const navbarBrand = document.querySelector('.navbar .navbar-brand');

// Create the button element
const button = document.createElement('button');
button.className = 'btn btn-default action-button btn-sm';
button.id = 'clear';
button.type = 'button';
button.innerHTML = '📝 New Chat';

// Insert the button after .navbar-brand
if (navbarBrand && navbarBrand.parentNode) {
  navbarBrand.parentNode.insertBefore(button, navbarBrand.nextSibling);
}
