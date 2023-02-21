

<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/masterquiroga/rappicard-bi-challenge">
    <img src="https://static.wixstatic.com/media/7b75ba_f5aa4a7f58ca451b8eb7ba47ee1cbec1~mv2.png/v1/fill/w_188,h_44,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/RappiCard_logo_footer.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">RappiCard BI Challenge </h3>

  <p align="center">
    Submission   for the RappiCard BI Challenge.
    <br />
    By Víctor G. G. Quiroga
    <br />
    <a href="https://github.com/masterquiroga/rappicard-bi-challenge"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/masterquiroga/rappicard-bi-challenge">View Demo</a>
    ·
    <a href="https://github.com/masterquiroga/rappicard-bi-challenge/issues">Report Bug</a>
    ·
    <a href="https://github.com/masterquiroga/rappicard-bi-challenge/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://github.com/masterquiroga/rappicard-bi-challenge)

This is the Solution for the RappiCard BI Challenge:

## Objective
The goal of this challenge is to exploit the information contained in an XLSX file with credit card information and transactions from multiple customers. The aim is to use a data visualization tool or programming language to explore the data and present the results. The database has the following architecture:

| Column | Description |
| ------ | ----------- |
| ID | This is the user’s unique identifier. |
| UPDATE | Date when the event happened. |
| STATUS | The event, which can take the following values: `EMPTY`, `RESPONSE`, `RISK`, `REJECTED`, `APPROVED`, or `DELIVERED`. |
| MOTIVE | The reason of rejection OR the type of card. |
| INTEREST_RATE | The interest rate of the customer’s credit card. |
| AMOUNT | The amount of the credit granted to the customer. |
| CAT | The annual cost of the credit granted to the customer. |
| TXN | The amount of each transaction for each customer. |
| CP | Zip Code where the physical credit card was delivered to. |
| DELIVERY_SCORE | A score the customer gives to the delivery company for the delivery service. |

Usually, the sign-up process starts when the customer responded to the communication and ends-up with an approval, either with physical or digital card.

## Tasks
Your task is to explore the data and present the results as you find fit. Some things to take into consideration are:

### 1. Data Exploration
Use your favorite data visualization tool or programming language (e.g. R, Python, PowerBI, Spotfire) to explore the data and answer the following questions:

- What is the distribution of credit approvals and rejections across the different categories of motives?
- What is the relationship between the customer's credit score and the interest rate of the credit card?
- What is the average transaction amount for customers in different zip codes?
- What is the average delivery score for customers in different zip codes?

### 2. Relevant Information
Display and plot the information you consider to be the most relevant for a credit card business. You could consider the following departments:

- Operations
- Growth (Marketing)
- Finance
- Customer Service
- Product

### 3. Key Performance Indicators
Use your imagination to best describe the data with charts and tables. Select those key performance indicators you consider that drive the business. Present recommendations on those indicators that, to the best of your knowledge, might be low or could be boosted.

### 4. Extra Information
Think outside the box. If you feel that extra information might be needed to support your arguments, include it in the folder (PowerPoint presentations, Word documents, etc.).


<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Built With

* [![pyenv][pyenv]][pyenv-url]
* [![Pipenv][Pipenv]][Pipenv-url]
* [![Python][Python]][Python-url]
* [![VSCode][VSCode]][VSCode-url]


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See the [`LICENSE`](./LICENSE) file for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

[Víctor Gerardo González Quiroga](https://linkedin.com/in/masterquiroga) for the full ownership of this project.

Project Link: [https://github.com/masterquiroga/rappicard-bi-challenge](https://github.com/masterquiroga/rappicard-bi-challenge)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Eduardo Rendón](https://www.linkedin.com/in/eduardorendona/) for the invitation and opportunity to this challenge.
* [Jesús Méndez](https://www.linkedin.com/in/jes%C3%BAs-m%C3%A9ndez-1381b6124/) for the technical validation of this challenge.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/masterquiroga/rappicard-bi-challenge.svg?style=for-the-badge
[contributors-url]: https://github.com/masterquiroga/rappicard-bi-challenge/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/masterquiroga/rappicard-bi-challenge.svg?style=for-the-badge
[forks-url]: https://github.com/masterquiroga/rappicard-bi-challenge/network/members
[stars-shield]: https://img.shields.io/github/stars/masterquiroga/rappicard-bi-challenge.svg?style=for-the-badge
[stars-url]: https://github.com/masterquiroga/rappicard-bi-challenge/stargazers
[issues-shield]: https://img.shields.io/github/issues/masterquiroga/rappicard-bi-challenge.svg?style=for-the-badge
[issues-url]: https://github.com/masterquiroga/rappicard-bi-challenge/issues
[license-shield]: https://img.shields.io/github/license/masterquiroga/rappicard-bi-challenge.svg?style=for-the-badge
[license-url]: https://github.com/masterquiroga/rappicard-bi-challenge/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-blue.svg?style=for-the-badge&logo=linkedin&colorB=blue
[linkedin-url]: https://linkedin.com/in/masterquiroga
[product-screenshot]: welcome.gif

[pyenv]: https://img.shields.io/badge/2.3.7-444444?style=for-the-badge&logo=pypy&logoColor=yellow&label=pyenv&labelColor=193440
[pyenv-url]: https://github.com/pyenv/pyenv

[Pipenv]: https://img.shields.io/badge/2022.9.8-444444?style=for-the-badge&logo=pypi&logoColor=white&label=pipenv&labelColor=222222
[Pipenv-url]: https://pipenv.pypa.io

[Python]: https://img.shields.io/badge/3.10.1-444444?style=for-the-badge&logo=python&logoColor=ffd343&label=Python&labelColor=3776AB
[Python-url]: https://python.org

[VSCode]: https://img.shields.io/badge/1.70.2-444444?style=for-the-badge&logo=visualstudiocode&logoColor=white&label=VSCode&labelColor=007ACC
[VSCode-url]: https://code.visualstudio.com/

[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 






