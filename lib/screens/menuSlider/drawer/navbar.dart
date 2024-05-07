import React, { useState, useEffect } from 'react';
import { Navbar, Nav, Container } from 'react-bootstrap';
import '../styles/NavigationBar.css';

function NavigationBar() {
    const [scroll, setScroll] = useState(false);
    const [underlineWidth, setUnderlineWidth] = useState('0%');

    useEffect(() => {
        const handleScroll = () => {
            setScroll(window.scrollY > 50);
        }; 

        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const navbarStyle = {
        backgroundColor: scroll ? '#000' : '#343a40',
        borderBottom: '3px solid #ff4500',
        transition: 'background-color 0.3s ease'
    };

    const linkStyle = {
        color: 'white',
        fontWeight: 'bold',
        marginRight: '20px',
        textShadow: '1px 1px 3px rgba(0, 0, 0, 0.6)',
        position: 'relative',
    };

    const underlineStyle = {
        position: 'absolute',
        left: 0,
        bottom: 3,
        width: underlineWidth,
        height: 2,
        backgroundColor: '#E8FBFC',
        transition: 'width 0.3s ease',
    };

    const handleMouseOver = () => {
        setUnderlineWidth('100%');
    };

    const handleMouseOut = () => {
        setUnderlineWidth('0%');
    };

    return (
        <Navbar style={navbarStyle} expand="lg" fixed="top">
            <Container>
                <Navbar.Brand href="#home" className={`brand-colored ${scroll ? 'brand-scrolled' : ''}`}>RapidJobs</Navbar.Brand>
                <Navbar.Toggle aria-controls="basic-navbar-nav" style={{ backgroundColor: 'white' }} />
                <Navbar.Collapse id="basic-navbar-nav" >
                    <Nav className="ms-auto">
                        <Nav.Link href="#home" style={linkStyle} onMouseOver={handleMouseOver} onMouseOut={handleMouseOut}>
                            Inicio
                            <div className="underline" style={underlineStyle}></div>
                        </Nav.Link>
                        <Nav.Link href="#home1" style={linkStyle} onMouseOver={handleMouseOver} onMouseOut={handleMouseOut}>
                            Ayuda
                            <div className="underline" style={underlineStyle}></div>
                        </Nav.Link>
                        <Nav.Link href="#home2" style={linkStyle} onMouseOver={handleMouseOver} onMouseOut={handleMouseOut}>
                            Términos y condiciones
                            <div className="underline" style={underlineStyle}></div>
                        </Nav.Link>
                        <Nav.Link href="#home3" style={linkStyle} onMouseOver={handleMouseOver} onMouseOut={handleMouseOut}>
                            Guía
                            <div className="underline" style={underlineStyle}></div>
                        </Nav.Link>
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    );
}

export default NavigationBar;