/* ===================================================================
   HopNSplat Landing Page — Scripts
   Navbar, mobile menu, stars, scroll reveal, video, alien animation.
   =================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  initNavbar();
  initMobileMenu();
  initStars();
  initScrollReveal();
  initVideoPlayer();
  initParallax();
});

/* ── Navbar scroll effect ── */
function initNavbar() {
  const navbar = document.getElementById('navbar');
  let ticking = false;

  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        navbar.classList.toggle('scrolled', window.scrollY > 60);
        ticking = false;
      });
      ticking = true;
    }
  });
}

/* ── Mobile hamburger menu ── */
function initMobileMenu() {
  const hamburger = document.getElementById('hamburger');
  const navLinks = document.getElementById('navLinks');

  hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('active');
    navLinks.classList.toggle('open');
  });

  navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      hamburger.classList.remove('active');
      navLinks.classList.remove('open');
    });
  });
}

/* ── Twinkling star particles ── */
function initStars() {
  const container = document.getElementById('heroStars');
  if (!container) return;

  const count = 80;

  for (let i = 0; i < count; i++) {
    const star = document.createElement('div');
    star.className = 'star';
    star.style.left = `${Math.random() * 100}%`;
    star.style.top = `${Math.random() * 100}%`;

    const size = Math.random() * 2.5 + 0.5;
    star.style.width = `${size}px`;
    star.style.height = `${size}px`;

    const duration = Math.random() * 3 + 2;
    star.style.setProperty('--dur', `${duration}s`);
    star.style.animationDelay = `${Math.random() * duration}s`;

    container.appendChild(star);
  }
}

/* ── Scroll Reveal (IntersectionObserver) ── */
function initScrollReveal() {
  const reveals = document.querySelectorAll('.reveal-up, .reveal-left, .reveal-right');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.15,
    rootMargin: '0px 0px -40px 0px'
  });

  reveals.forEach(el => observer.observe(el));
}

/* ── Video Player ── */
function initVideoPlayer() {
  const video = document.getElementById('gameplayVideo');
  const overlay = document.getElementById('videoPlayOverlay');
  if (!video || !overlay) return;

  overlay.addEventListener('click', () => {
    video.play();
    overlay.classList.add('hidden');
  });

  video.addEventListener('pause', () => {
    overlay.classList.remove('hidden');
  });

  video.addEventListener('ended', () => {
    overlay.classList.remove('hidden');
  });

  // Auto-play when in view, pause when out
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        video.play().catch(() => {});
        overlay.classList.add('hidden');
      } else {
        video.pause();
      }
    });
  }, { threshold: 0.5 });

  observer.observe(video.closest('.phone-mockup'));
}

/* ── Subtle parallax on hero elements ── */
function initParallax() {
  const hero = document.getElementById('hero');
  if (!hero) return;

  const platforms = hero.querySelectorAll('.platform-el');
  const clouds = hero.querySelectorAll('.cloud-sprite');
  const alien = document.getElementById('alienContainer');

  let ticking = false;

  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        const scrollY = window.scrollY;
        const heroH = hero.offsetHeight;

        if (scrollY < heroH) {
          const ratio = scrollY / heroH;

          platforms.forEach((p, i) => {
            const speed = (i + 1) * 0.15;
            p.style.transform = `translateY(${scrollY * speed}px)`;
          });

          clouds.forEach((c, i) => {
            const speed = (i + 1) * 0.08;
            c.style.transform = `translateY(${scrollY * speed}px)`;
          });

          if (alien) {
            alien.style.transform = `translateX(-50%) translateY(${scrollY * 0.2}px)`;
          }
        }

        ticking = false;
      });
      ticking = true;
    }
  });
}
