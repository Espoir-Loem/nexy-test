import { hydrateRoot } from 'react-dom/client'
import React from 'react'
import { ThemeButton as Component } from '../../../../../src/components/theme'

const el = document.getElementById('theme.ThemeButton-root')
if (el) hydrateRoot(el, React.createElement(Component))